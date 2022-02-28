//
//  AdjustedHistoricalPrices.swift
//  Stocks
//
//  Created by Андрей Бучевский on 14.02.2022.
//

import Foundation
import Charts

struct AdjustedHistoricalPrice {
    var index: Int
    var highPrice: Double
    var date: String
    
    init?(historicalPrice: HistoricalPrice, index: Int) {
        self.highPrice = historicalPrice.high
        
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM-dd"
        //        let date = dateFormatter.date(from: historicalPrice.date)
        //        let date = getMonthInfo(for: historicalPrice)
        //        self.date = date!
        self.date = historicalPrice.date
        self.index = index
    }
    
    func transformToBarChartDataEntry() -> BarChartDataEntry {
        let entry = BarChartDataEntry(x: Double(index), y: highPrice)
        return entry
    }
}


