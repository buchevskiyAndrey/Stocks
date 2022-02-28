//
//  ErrorManager.swift
//  Stocks
//
//  Created by Андрей Бучевский on 24.02.2022.
//

import Foundation


enum ErrorManager: Error, LocalizedError {
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
