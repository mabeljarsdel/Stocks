//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Maria Kramer on 01.09.2021.
//

import Foundation

// Object to manage saved caches
class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        static let onboarded = "hasOnboarded"
        static let watchlist = "watchlist"
    }
    
    private init () {}
    
    // MARK: - Public
    
    // Get user watch list
    public var watchList: [String] {
        if !hasOnboarded{
            userDefaults.set(true, forKey: Constants.onboarded)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlist) ?? []
    }
    
    // Check if watch list contains item
    public func watchlistContains(symbol: String) -> Bool {
        return watchList.contains(symbol)
    }
    
    // Add company name for symbol to watch list
    public func addToWatchList(symbol: String, companyName: String) {
        var current = watchList
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchlist)
        userDefaults.set(companyName, forKey: symbol)
        
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    
    // Remove item from watch list
    public func removeFromWatchList(symbol: String) {
        var newList = [String]()
        userDefaults.set(nil, forKey: symbol)
        for item in watchList where item != symbol {
            
            newList.append(item)
        }
        userDefaults.set(newList, forKey: Constants.watchlist)
    }
    
    // MARK: - Private
    
    // Check if user has been onboarded
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboarded)
    }
    
    // Set up default watch list
    private func setUpDefaults(){
        let map: [String: String] = [
            "SPOT": "Spotify Technology S.A.",
            "AAPL": "Apple Inc.",
            "MSFT": "Microsoft Corporation",
            "SNAP": "Snap Inc.",
            "GOOG": "Alphabet Inc.",
            "NVDA": "Nvidia Corporation"
        ]
        
        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchlist)
        
        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
}
