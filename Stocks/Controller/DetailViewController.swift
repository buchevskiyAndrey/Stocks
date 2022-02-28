//
//  ViewController.swift
//  Stocks
//
//  Created by Андрей Бучевский on 07.02.2022.
//

import UIKit
import Charts

class DetailViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var historicPriceLabel: UILabel!
    
    //MARK: - Public properties
    var selectedSymbol: String!
    
    //MARK: - Private properties
    private var networkManager: NetworkDetailsProtocol!
    private let group = DispatchGroup()
    private var qouteData: QouteData?
    private var imageData: ImageData?
    private var adjustedHistoricalPrices: [AdjustedHistoricalPrice] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager = NetworkManager()
        companyNameLabel.text = "Tinkoff"
        networkManager.delegate = self
        setUpActivityIndicator()
        qouteReset()
        
        //Get detailed data
        networkManager.request(for: selectedSymbol) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error ):
                DispatchQueue.main.async {
                    self.alertForError(title: "Something goes wrong", message: "\(error.localizedDescription)", preferredStyle: .alert)
                }
            case .success(let company):
                self.networkManager.updateInterface(for: company!)
            }
        }
        
        //Get data for barChart
        networkManager.fetchHistoricalPrice(for: selectedSymbol) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                switch result {
                case.failure(let error):
                    self.alertForError(title: "Something goes wrong", message: "\(error.localizedDescription)", preferredStyle: .alert)
                case .success(let historicalPrices):
                    var counter = 0
                    historicalPrices?.forEach{ item in
                        guard let adjustedHistoricalPrice = AdjustedHistoricalPrice(historicalPrice: item, index: counter) else { return }
                        counter += 1
                        self.adjustedHistoricalPrices.append(adjustedHistoricalPrice)
                    }
                    self.createChart()
                }
            }
        }
    }
    
    //MARK: - Private methods
    private func qouteReset() {
        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.companySymbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
        self.currencyLabel.text = ""
        self.priceChangeLabel.textColor = .white
        self.historicPriceLabel.text = ""
        self.dateLabel.text = ""
    }
    
    private func setUpActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -75).isActive = true
    }
    
    private func alertForError(title: String, message: String?, preferredStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


//MARK: - Extensions
extension DetailViewController: DetailsManagerProtocol {
    func distplayInfo(_: NetworkManager, qoute: QouteData) {
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = qoute.companyName
        self.companySymbolLabel.text = qoute.symbol
        self.currencyLabel.text = qoute.currency
        self.priceLabel.text = "\(qoute.latestPrice)"
        self.priceChangeLabel.text = String(format: "%.3f", qoute.changePercent) + "%"
        
        if qoute.changePercent > 0 {
            self.priceChangeLabel.textColor = .green
        } else if qoute.changePercent < 0 {
            self.priceChangeLabel.textColor = .red
        } else {
            self.priceChangeLabel.textColor = .white
        }
    }
    
    func distplayImage(_: NetworkManager, image: UIImage) {
        self.logoView.image = image
    }
}

//Set up chartBar
extension DetailViewController: ChartViewDelegate {
    private func setupData() {
        let dataEntries = adjustedHistoricalPrices.map{ $0.transformToBarChartDataEntry() }
        
        let set1 = BarChartDataSet(entries: dataEntries)
        set1.setColor(.systemYellow)
        set1.highlightColor = .yellow
        set1.highlightAlpha = 1
        
        let data = BarChartData(dataSet: set1)
        data.setDrawValues(false)
        data.setValueTextColor(.white)
        barChart.data = data
    }
    
    
    private func createChart() {
        setupData()
        barChart.delegate = self
        
        // Hightlight
        barChart.highlightPerTapEnabled = true
        barChart.highlightFullBarEnabled = true
        barChart.highlightPerDragEnabled = false
        
        // disable zoom function
        barChart.pinchZoomEnabled = false
        barChart.setScaleEnabled(false)
        barChart.doubleTapToZoomEnabled = false
        
        // Bar, Grid Line, Background
        barChart.drawBarShadowEnabled = false
        barChart.drawGridBackgroundEnabled = false
        barChart.drawBordersEnabled = false
        barChart.borderColor = .white
        
        // Legend
        barChart.legend.enabled = false
        
        // Chart Offset
        barChart.setExtraOffsets(left: 10, top: 0, right: 20, bottom: 50)
        
        barChart.rightAxis.enabled = false
        barChart.xAxis.enabled = false
        
        
        let yAxis = barChart.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.labelTextColor = .white
        yAxis.setLabelCount(6, force: false)
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        
        barChart.animate(xAxisDuration: 2.5, easingOption: .easeOutQuart)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        dateLabel.text = adjustedHistoricalPrices[Int(entry.x)].date
        historicPriceLabel.text = String(entry.y)
    }
}

