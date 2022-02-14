//
//  ViewController.swift
//  Stocks
//
//  Created by Андрей Бучевский on 07.02.2022.
//

import UIKit

class DetailViewController: UIViewController {
//MARK: - IBOutlet
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoView: UIImageView!
    
//MARK: - Public properties
    var selectedSymbol: String!
    
//MARK: - Private properties
    private var detailsManager: NetworkDetailsProtocol!
    private let group = DispatchGroup()
    private var qouteData: QouteData?
    private var imageData: ImageData?
    
//MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        detailsManager = DetailsManager()
        companyNameLabel.text = "Tinkoff"
        detailsManager.delegate = self
        activityIndicator.hidesWhenStopped = true
        qouteReset()
        
        detailsManager.request(for: selectedSymbol) { [unowned self] result in
            switch result {
            case .failure(let error ):
//                switch error {
//                case
//                }
                DispatchQueue.main.async {
                    self.alertForError(title: "Something goes wrong", message: "\(error.localizedDescription)", preferredStyle: .alert)
                }
            case .success(let company):
            
                self.detailsManager.updateInterface(for: company!)
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
    }
}


//MARK: - Extensions
extension DetailViewController: DetailsManagerProtocol {
    func distplayInfo(_: DetailsManager, qoute: QouteData) {
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
    
    func distplayImage(_: DetailsManager, image: ImageData) {
        self.logoView.image = image.image
    }
}

extension DetailViewController {
    private func alertForError(title: String, message: String?, preferredStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
