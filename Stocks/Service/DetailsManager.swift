//
//  NetworkManager.swift
//  Stocks
//
//  Created by Андрей Бучевский on 07.02.2022.
//

import Foundation
import UIKit

protocol NetworkDetailsProtocol {
    var delegate: DetailsManagerProtocol? {get set}
    
    func request(for symbol: String, completion: @escaping (Result<Company?, Error>) -> Void)
    func fetchHistoricalPrices(for symbol: String, completion: @escaping (Result<[HistoricalPrice]?, Error>) -> Void)
    func updateInterface(for company: Company)
}

protocol DetailsManagerProtocol: AnyObject {
    func distplayInfo(_: DetailsManager, qoute: QouteData)
    func distplayImage(_: DetailsManager, image: ImageData)
}

class DetailsManager {
    //MARK: - Error Handling
    enum DetailsManagerError: Error, LocalizedError {
        case badRequest
        case internalError
        case invalidInput
        var errorDescription: String? {
            switch self {
            case .badRequest:
                return NSLocalizedString("Check your connection", comment: "Poor connection")
            case .internalError:
                return NSLocalizedString("App is broken :(", comment: "My error")
            case .invalidInput:
                return NSLocalizedString("The server hasn't found detailed information", comment: "API's problem")
            }
        }
    }
    
    //MARK: - Public properties
    weak var delegate: DetailsManagerProtocol?
    
    //MARK: - Private properties
    private let group = DispatchGroup()
    private let keys = [apiKeyForDetailedInfo1, apiKeyForDetailedInfo2, apiKeyForDetailedInfo3]
    private var key: String {
        return keys.randomElement() ?? ""
    }
    
    //MARK: - Private methods
    private func fetchQoute(for symbol: String, completion: @escaping (Result<QouteData?, Error>) -> Void) {
        let selectedSymbol = symbol.split(separator: ".").joined(separator: "-")
        let urlStringForQuote = "https://cloud.iexapis.com/stable/stock/\(selectedSymbol)/quote/displayPercent=true?&token=\(key)"
        let urlResult = parseURL(urlString: urlStringForQuote)
        switch urlResult {
        case .failure(let error):
            completion(.failure(error))
        case .success(let url):
            let session = URLSession(configuration: .default)
            group.enter()
            let task = session.dataTask(with: url) { data, response, error in
                defer {
                    self.group.leave()
                }
                guard
                    error == nil,
                    (response as? HTTPURLResponse)?.statusCode == 200,
                    let data = data
                else {
                    guard let error = error else {
                        completion(.failure(DetailsManagerError.invalidInput))
                        return
                    }
                    completion(.failure(error))
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let qouteData = try decoder.decode(QouteData.self, from: data)
                    completion(.success(qouteData))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func fetchImage(for symbol: String, completion: @escaping (Result<ImageData?, Error>) -> Void) {
        let selectedSymbol = symbol.split(separator: ".").joined(separator: "-")
        let urlStringForImage = "https://cloud.iexapis.com/stable/stock/\(selectedSymbol)/logo/quote?&token=\(key)"
        let urlResult = parseURL(urlString: urlStringForImage)
        switch urlResult {
        case.failure(let error):
            completion(.failure(error))
        case.success(let url):
            let session = URLSession(configuration: .default)
            group.enter()
            let task = session.dataTask(with: url) { data, response, error in
                defer {
                    self.group.leave()
                }
                guard
                    error == nil,
                    (response as? HTTPURLResponse)?.statusCode == 200,
                    let data = data
                else {
                    guard let error = error else {
                        completion(.failure(DetailsManagerError.invalidInput))
                        return
                    }
                    completion(.failure(error))
                    return
                }
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data)
                    guard
                        let json = jsonObject as? [String: Any],
                        let urlImage = json["url"] as? String
                    else {
                        completion(.failure(DetailsManagerError.badRequest))
                        return
                    }
                    let image = self.getImageFromString(urlImage)
                    switch image {
                    case .success(let image):
                        guard let image = image else {
                            return completion(.failure(DetailsManagerError.internalError))
                        }
                        let imageData = ImageData(image: image)
                        completion(.success(imageData))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    private func getImageFromString(_ string: String) -> Result<UIImage?, Error> {
        guard let url = URL(string: string)
        else {
            return .failure(DetailsManagerError.internalError)
        }
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
    
    private func parseURL(urlString: String) -> Result<URL, Error> {
        if let url = URL(string: urlString) {
            return .success(url)
        } else {
            return .failure(DetailsManagerError.badRequest)
        }
    }
    
}

extension DetailsManager: NetworkDetailsProtocol {
    //MARK: - Public methods
    func request(for symbol: String, completion: @escaping (Result<Company?, Error>) -> Void) {
        var qouteData: QouteData?
        var imageData: ImageData?
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
            case .success(let image):
                
                imageData = image
            }
        }
        group.notify(queue: .main) {
            guard let qouteData = qouteData, let imageData = imageData
            else {
                completion(.failure(DetailsManagerError.invalidInput))
                return
            }
            guard let company = Company(qouteData: qouteData, imageData: imageData)
            else {
                completion(.failure(DetailsManagerError.internalError))
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


extension DetailsManager {
    func fetchHistoricalPrices(for symbol: String, completion: @escaping (Result<[HistoricalPrice]?, Error>) -> Void) {
        let selectedSymbol = symbol.split(separator: ".").joined(separator: "-")
        let urlStringForQuote = "https://cloud.iexapis.com/stable/stock/\(selectedSymbol)/chart/1y?token=\(key)"
        let urlResult = parseURL(urlString: urlStringForQuote)
        switch urlResult {
        case .failure(let error):
            completion(.failure(error))
        case .success(let url):
            let session = URLSession(configuration: .default)
            group.enter()
            let task = session.dataTask(with: url) { data, response, error in
                defer {
                    self.group.leave()
                }
                guard
                    error == nil,
                    (response as? HTTPURLResponse)?.statusCode == 200,
                    let data = data
                else {
                    guard let error = error else {
                        completion(.failure(DetailsManagerError.invalidInput))
                        return
                    }
                    completion(.failure(error))
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let qouteData = try decoder.decode([HistoricalPrice].self, from: data)
                    completion(.success(qouteData))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
}
