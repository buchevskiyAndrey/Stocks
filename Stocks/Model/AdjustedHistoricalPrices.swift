//
//  AdjustedHistoricalPrices.swift
//  Stocks
//
//  Created by Андрей Бучевский on 14.02.2022.
//

import Foundation

struct AdjustedHistoricalPrices {
    var highPrice: Double
    var date: Date
    
    init?(highPrice: Double, data: Date) {
        self.highPrice = highPrice
        self.date = data
    }
   
}


