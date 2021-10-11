//
//  APICaller.swift
//  Stocks
//
//  Created by Maria Kramer on 01.09.2021.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private struct Constants {
        static let apiKey = "c4oabqaad3ia3dsrv970"
        static let sendBoxApiKey = "sandbox_c4oabqaad3ia3dsrv97g"
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    
    private init() {}
    
    // MARK: - Public
    
    // Search for a particular company
    public func search(
        query: String,
        completion: @escaping (Result<SearchResponse, Error>) -> Void
    ) {
        
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            return
        }
        
        let urlStocks = url(
            for: .search,
            queryParams: ["q": safeQuery]
        )
        
        request(
            url: urlStocks,
            expecting: SearchResponse.self,
            completion: completion
        )
    }
    
    // Get news for type (company or top stories)
    public func news(
        for type: NewsViewController.`Type`,
        completion: @escaping(Result<[NewsStory], Error>) -> Void
    ){
        switch type {
        case .topStories :
            let urlNews = url(
                for: .topStories,
                queryParams: ["category" : "general"]
            )
            request(
                url: urlNews,
                expecting: [NewsStory].self,
                completion: completion
            )
            
        case .compan(let symbol):
            let today = Date()
            let oneWeekBack = today.addingTimeInterval(-(Constants.day * 7))
            let urlCompanyNews = url(
                for: .companyNews,
                queryParams: [
                    "symbol" : symbol,
                    "from": DateFormatter.newsDateFormatter.string(from: oneWeekBack),
                    "to": DateFormatter.newsDateFormatter.string(from: today)
                ]
            )
            request(
                url: urlCompanyNews,
                expecting: [NewsStory].self,
                completion: completion
            )
        }
    }
    
    // Get market data for given symbol
    public func marketData(
        for symbol: String,
        numberOfDays: TimeInterval = 7,
        completion: @escaping (Result<MarketDataResponse,Error>) -> Void
    ){
        let today = Date().addingTimeInterval(-(Constants.day))
        let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
        let urlMarketData = url(
            for: .marketData,
            queryParams: [
                "symbol": symbol,
                "resolution": "1",
                "from": "\(Int(prior.timeIntervalSince1970))",
                "to": "\(Int(today.timeIntervalSince1970))"
            ]
        )
        request(
            url: urlMarketData,
            expecting: MarketDataResponse.self,
            completion: completion
        )
    }
    
    // Get financial metrics for given symbol of company
    public func financialMetrics(
        for symbol: String,
        completion: @escaping (Result <FinancialMetricsResponse, Error>) -> Void
    ){
        let urlFinancialMetrics = url(
            for: .financials,
            queryParams: ["symbol": symbol, "metric": "all"]
        )
        
        request(
            url: urlFinancialMetrics,
            expecting: FinancialMetricsResponse.self,
            completion: completion
        )
    }
    
    // MARK: - Private
    
    private enum Endpoint: String {
        // API endpoints
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidURL
    }
    
    // Try to create url for endpoint
    private func url(
        for endpoint: Endpoint,
        queryParams: [String: String] = [:]
    ) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        // Add any parameters
        for(name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        // Add token
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        
        urlString += "?" + queryString
        
        return URL(string: urlString)
    }
    
    // Perform api call
    private func request<T: Codable> (
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
