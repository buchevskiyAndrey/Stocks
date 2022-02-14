//
//  TableViewCell.swift
//  Stocks
//
//  Created by Андрей Бучевский on 11.02.2022.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var assetSymbolLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!
    @IBOutlet weak var assetNameLabel: UILabel!
    
    func configure(with searchResult: SearchResult) {
        assetSymbolLabel.text = searchResult.symbol
        assetTypeLabel.text = searchResult.type + " " + searchResult.currency
        assetNameLabel.text = searchResult.name
    }

}



