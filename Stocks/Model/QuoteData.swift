//
//  QuoteData.swift
//  Stocks
//
//  Created by Андрей Бучевский on 10.02.2022.
//

import Foundation


struct QouteData: Decodable {
    let companyName: String
    let symbol: String
    let latestPrice: Double
    let changePercent: Double
    let currency: String
}
