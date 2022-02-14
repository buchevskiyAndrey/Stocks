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
}

