//
//  Company.swift
//  Stocks
//
//  Created by Андрей Бучевский on 14.02.2022.
//

import Foundation
import UIKit

struct Company {
    let qouteData: QouteData
    let imageData: ImageData
    init?(qouteData: QouteData, imageData: ImageData) {
        self.qouteData = qouteData
        self.imageData = imageData
    }
//    
//    let companyName: String
//    let symbol: String
//    let price: Double
//    let priceChange: Double
//    let image: UIImage
//
//    init?(companyName: String, symbol: String, price: Double, priceChange: Double, image: UIImage) {
//        self.companyName = companyName
//        self.symbol = symbol
//        self.price = price
//        self.priceChange = priceChange
//        self.image = image
//    }

}
