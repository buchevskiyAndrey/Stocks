//
//  SearchManager.swift
//  Stocks
//
//  Created by Андрей Бучевский on 11.02.2022.
//

import Foundation

protocol NetworkSearchProtocol {
    func fetchSymbol(for symbol: String, completion: @escaping (Result<SearchResults?, Error>) -> Void)
}

class SearchManager: NetworkSearchProtocol {
//MARK: - Error Handling
    enum SearchManagerError: Error {
        case badRequest
    }
    
//MARK: - Private properties
    private let keys = [apiKeyForSearch1, apiKeyForSearch2, apiKeyForSearch3]
    private var key: String {
        return keys.randomElement() ?? ""
    }
    
//MARK: - Public methods
    func fetchSymbol(for symbol: String, completion: @escaping (Result<SearchResults?, Error>) -> Void)  {
        let selectedSymbol = symbol.split(separator: " ").joined(separator: "%20")
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(selectedSymbol)&apikey=\(key)"
        
        let urlResult = parseURL(urlString: urlString)
        switch urlResult {
            
        case .success(let url):
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                guard
                    error == nil,
                    (response as? HTTPURLResponse)?.statusCode == 200,
                    let data = data
                else {
                    completion(.failure(error!))
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let searchResults = try decoder.decode(SearchResults.self, from: data)
                    completion(.success(searchResults))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
            
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
//MARK: - Private methods
    private func parseURL(urlString: String) -> Result<URL, Error> {
        if let url = URL(string: urlString) {
            return .success(url)
        } else {
            return .failure(SearchManagerError.badRequest)
        }
    }
}

