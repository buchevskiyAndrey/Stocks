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
    let imageData: UIImage
    
    init?(qouteData: QouteData, imageData: UIImage) {
        self.qouteData = qouteData
        self.imageData = imageData
    }
}

