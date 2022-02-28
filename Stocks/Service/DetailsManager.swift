//
//  NetworkManager.swift
//  Stocks
//
//  Created by Андрей Бучевский on 07.02.2022.
//

import Foundation
import UIKit

protocol NetworkSearchProtocol {
    func fetchSymbol(for symbol: String, completion: @escaping (Result<SearchResults?, Error>) -> Void)
}

protocol NetworkDetailsProtocol {
    var delegate: DetailsManagerProtocol? {get set}
    
    func request(for symbol: String, completion: @escaping (Result<Company?, Error>) -> Void)
    func fetchHistoricalPrice(for symbol: String, completion: @escaping (Result<[HistoricalPrice]?, Error>) -> Void)
    func updateInterface(for company: Company)
}

protocol DetailsManagerProtocol: AnyObject {
    func distplayInfo(_: NetworkManager, qoute: QouteData)
    func distplayImage(_: NetworkManager, image: UIImage)
}

class NetworkManager {
    //MARK: - Public properties
    weak var delegate: DetailsManagerProtocol?
    
    //MARK: - Private properties
    private let group = DispatchGroup()
    //    private let keys = [apiKeyForDetailedInfo1, apiKeyForDetailedInfo2, apiKeyForDetailedInfo3]
    private let keysForDetails = [apiKeyForDetailedInfo2, apiKeyForDetailedInfo3]
    private var keyForDetails: String {
        return keysForDetails.randomElement() ?? ""
    }
    
    private let keysForSearch = [apiKeyForSearch1, apiKeyForSearch2, apiKeyForSearch3]
    private var keyForSearch: String {
        return keysForSearch.randomElement() ?? ""
    }
    //MARK: - Private method
    private func fetchQoute(for symbol: String, completion: @escaping (Result<QouteData?, Error>) -> Void) {
        let selectedSymbol = symbol.split(separator: ".").joined(separator: "-")
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(selectedSymbol)/quote/displayPercent=true?&token=\(keyForDetails)")
        group.enter()
        
        URLSession.shared.request1(url: url, expecting: QouteData.self) { result in
            defer {
                self.group.leave()
            }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let qouteData):
                completion(.success(qouteData))
            }
        }
    }
    
    
    private func fetchImage(for symbol: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        let selectedSymbol = symbol.split(separator: ".").joined(separator: "-")
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(selectedSymbol)/logo/quote?&token=\(keyForDetails)")
        group.enter()
        
        URLSession.shared.request1(url: url, expecting: ImageData.self) { [weak self] result in
            guard let self = self else { return }
            defer {
                self.group.leave()
            }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let imageData):
                let image = self.getImageFromData(imageData)
                switch image {
                case .success(let image):
                    guard let image = image else {
                        return completion(.failure(ErrorManager.internalError))
                    }
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
   

    private func getImageFromData(_ imageData: ImageData) -> Result<UIImage?, Error> {
        let url = imageData.url
        var image: UIImage? = nil
        do {
            let data = try Data(contentsOf: url)
            image = UIImage(data: data)
            return .success(image)
        }
        catch {
            return .failure(error)
        }
    }
    
}

extension NetworkManager: NetworkDetailsProtocol {
    //MARK: - Public methods
    //Fetch data with historical prices for BarChart
    func fetchHistoricalPrice(for symbol: String, completion: @escaping (Result<[HistoricalPrice]?, Error>) -> Void) {
        let selectedSymbol = symbol.split(separator: ".").joined(separator: "-")
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(selectedSymbol)/chart/1m?token=\(keyForDetails)")
        URLSession.shared.request1(url: url, expecting: [HistoricalPrice].self) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let historicalPrice):
                completion(.success(historicalPrice))
            }
        }
    }
    
    func request(for symbol: String, completion: @escaping (Result<Company?, Error>) -> Void) {
        var qouteData: QouteData?
        var image: UIImage?
        
        fetchQoute(for: symbol) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let qoute):
                qouteData = qoute
            }
        }
        
        fetchImage(for: symbol) { result in
            switch result{
            case .failure(let error):
                completion(.failure(error))
            case .success(let imageData):
                image = imageData
            }
        }
        group.notify(queue: .main) {
            guard let qouteData = qouteData, let imageData = image
            else {
                completion(.failure(ErrorManager.invalidInput))
                return
            }
            guard let company = Company(qouteData: qouteData, imageData: imageData)
            else {
                completion(.failure(ErrorManager.internalError))
                return
            }
            completion(.success(company))
        }
    }
    
    func updateInterface(for company: Company) {
        self.delegate?.distplayInfo(self, qoute: company.qouteData)
        self.delegate?.distplayImage(self, image: company.imageData)
    }
}


extension NetworkManager: NetworkSearchProtocol {
    func fetchSymbol(for symbol: String, completion: @escaping (Result<SearchResults?, Error>) -> Void) {
        let selectedSymbol = symbol.split(separator: " ").joined(separator: "%20")
        let url = URL(string: "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(selectedSymbol)&apikey=\(keyForSearch)")
        URLSession.shared.request1(url: url, expecting: SearchResults.self) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let searchResults):
                completion(.success(searchResults))
            }
        }
    }
}
