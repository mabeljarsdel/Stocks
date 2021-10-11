//
//  SearchResponse.swift
//  Stocks
//
//  Created by Maria Kramer on 25.09.2021.
//

import Foundation

// API response for search
struct SearchResponse: Codable {
    let count: Int
    let result: [SearchResult]
}

struct SearchResult: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
