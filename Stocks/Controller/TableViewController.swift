//
//  TableViewController.swift
//  Stocks
//
//  Created by Андрей Бучевский on 11.02.2022.
//

import UIKit


class TableViewController: UITableViewController {
//MARK: - Private properties
    private let searchController = UISearchController(searchResultsController: nil)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var networkManager: NetworkSearchProtocol!
    private var searchQuery: String!
    private var searchTimer: Timer?
    private var searchResults: SearchResults?

    
//MARK: - View lifecyclke
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager = NetworkManager()
        setUpSearchBar()
        setUpActivityIndicator()
        tableView.backgroundView = SearchPlaceholderView()
    }
    
// MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.bestMatches.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        if let searchResults = self.searchResults {
            let searchResult = searchResults.bestMatches[indexPath.row]
            cell.configure(with: searchResult)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchResults = searchResults {
            let symbol = searchResults.bestMatches[indexPath.row].symbol
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            vc.selectedSymbol = symbol
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
//MARK: - Private methods
    private func setUpSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter a company name or symbol"
        searchController.searchBar.autocapitalizationType = .allCharacters
        searchController.searchBar.tintColor = .systemYellow
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.title = "Search"
        navigationController!.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.searchController = searchController
    }
    
    private func setUpActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80).isActive = true
    }
    
    private func alertForError(title: String, message: String?, preferredStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    } 
    
    @objc private  func performSearch() {
        activityIndicator.startAnimating()
        networkManager.fetchSymbol(for: self.searchQuery) {[weak self] completion in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch completion {
                case .success(let searchResults):
                    self.searchResults = searchResults
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                case .failure(let error):
                    self.activityIndicator.stopAnimating()
                    self.alertForError(title: "Something goes wrong", message: "\(error.localizedDescription)", preferredStyle: .alert)
                }
            }
        }
    }
}

//MARK: - Extensions
extension TableViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        tableView.backgroundView = nil
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else {return}
        self.searchQuery = searchQuery
    }
    
    //Устанавливает таймер на выполнение запроса при наборе текста в Search Bar'е
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.searchTimer?.invalidate()
        let currentText = searchBar.text ?? ""
        if (currentText as NSString).replacingCharacters(in: range, with: text).count >= 2 {
            self.searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
        }
        return true
    }
}

