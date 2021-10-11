//
//  SearchResultTableViewCell.swift
//  Stocks
//
//  Created by Maria Kramer on 02.09.2021.
//

import UIKit

// Tableview cell for search result
final class SearchResultTableViewCell: UITableViewCell {
    static let identifier = "SearchResultTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
