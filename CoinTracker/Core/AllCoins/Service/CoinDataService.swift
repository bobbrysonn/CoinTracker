//
//  CoinDataService.swift
//  CoinTracker
//
//  Created by Bob Moriasi on 4/23/24.
//

import Foundation

protocol HTTPDataDownloader {
    func fetchData<T: Decodable>(as type: T.Type, endpoint: String) async throws -> T
}

class CoinDataService: HTTPDataDownloader {
    // API KEY
    private let key = "CG-zwRnUM8eRJTXCsWJdyrsfz6E"
    
    private var baseURLComponents: URLComponents {
        var components = URLComponents()
        
        /* Set everything up */
        components.scheme = "https"
        components.host = "api.coingecko.com"
        components.path = "/api/v3/coins/"
        
        return components
    }
    
    private var fetchCoinsURL: String? {
        var components = baseURLComponents
        components.path += "markets"
        
        /* Add the query items */
        components.queryItems = [
            .init(name: "vs_currency", value: "usd"),
            .init(name: "order", value: "market_cap_desc"),
            .init(name: "per_page", value: "100"),
            .init(name: "page", value: "1"),
            .init(name: "sparkline", value: "false"),
            .init(name: "x_cg_demo_api_key", value: "\(self.key)")
        ]
        
        return components.url?.absoluteString
    }
    
    private func fetchCoinDetailsURL(coinID: String) -> String? {
        var components = baseURLComponents
        components.path += "\(coinID)"
        
        /* Add query items */
        components.queryItems = [
            .init(name: "localization", value: "true"),
            .init(name: "tickers", value: "false"),
            .init(name: "market_data", value: "false"),
            .init(name: "community_data", value: "false"),
            .init(name: "developer_data", value: "false"),
            .init(name: "x_cg_demo_api_key", value: "\(self.key)")
        ]
        
        return components.url?.absoluteString
    }
    
    /**
     Fetch coin details for a specific coin
     */
    func fetchCoinDetails(coinID: String) async throws -> CoinDetails {
        /* Check if we have cached data */
        if let cachedData = CoinDetailsCache.shared.get(forKey: coinID) {
            print("DEBUG: Fetched data from cache")
            return cachedData
        }
        
        /* Get the url */
        guard let url = fetchCoinDetailsURL(coinID: coinID) else {
            throw CoinAPIError.requestFailed(description: "Invalid URL construction")
        }
        
        /* Fetch the data */
        let coinDetails = try await fetchData(as: CoinDetails.self, endpoint: url)
        
        /* Cache data */
        CoinDetailsCache.shared.set(coinDetails, forKey: coinID)
        print("DEBUG: Fetched data from API")
        
        /* Return data */
        return coinDetails
    }
    
    func fetchCoinsWithAsync() async throws -> [Coin] {
        // Construct the URL
        guard let url = fetchCoinsURL else {
            throw CoinAPIError.requestFailed(description: "Invalid URL construction")
        }
        
        return try await fetchData(as: [Coin].self, endpoint: url)
    }
}




/**
 Fetch data implementation
 */
extension HTTPDataDownloader {
    func fetchData<T: Decodable>(as type: T.Type, endpoint: String) async throws -> T {
        // Convert URL
        guard let url = URL(string: endpoint) else {
            throw CoinAPIError.requestFailed(description: "Invalid URL")
        }
        
        // Fetch URL
        guard let (data, response) = try? await URLSession.shared.data(from: url) else {
            print("DEBUG: Error executing URLSession. Possibly non-existent hostname")
            throw CoinAPIError.datataskExecutionFailed(localizedDescription: "Error executing URLSession. Possibly non-existent hostname")
        }
        
        // Check that we got a valid response
        guard let httpResp = response as? HTTPURLResponse else {
            print("DEBUG: Did not get valid HTTP Response from URLSession")
            throw CoinAPIError.requestFailed(description: "Did not get valid HTTP Response from URLSession")
        }
        
        // Check we got valid status code
        guard 200...299 ~= httpResp.statusCode else {
            throw CoinAPIError.invalidStatusCode(statusCode: httpResp.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("DEBUG: JSON Decoding failed: \(error.localizedDescription)")
            throw error as? CoinAPIError ?? .jsonParsingFailed
        }
    }
}












// MARK: Completion handler stuff
extension CoinDataService {
    // Fetch all coins with result for the completion handler
    func fetchCoinsWithResult(completion: @escaping (Result<[Coin], CoinAPIError>) -> Void) {
        // Construct the URL
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false&x_cg_demo_api_key=\(self.key)"
        guard let url = URL(string: urlString) else { return }
        
        // Fetch request
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for error
            if let error {
                print("DEBUG: Failed with error \(error.localizedDescription)")
                completion(.failure(.datataskExecutionFailed(localizedDescription: error.localizedDescription)))
            }
            
            // Check we got response
            guard let httpResp = response as? HTTPURLResponse else {
                completion(.failure(.requestFailed(description: "Request failed")))
                return
            }
            
            // Check we got valid status code
            guard 200...299 ~= httpResp.statusCode else {
                completion(.failure(.invalidStatusCode(statusCode: httpResp.statusCode)))
                return
            }
            
            // Check we got valid data
            guard let data else {
                completion(.failure(.invalidData))
                return
            }
            
            // Convert data to JSON object and to array
            do {
                let coins = try JSONDecoder().decode([Coin].self, from: data)
                // Pass coins to completion handler
                completion(.success(coins))
            } catch {
                print("DEBUG: Failed to decode coins")
                completion(.failure(.jsonParsingFailed))
            }
        }.resume()
    }

    // Fetch all coins
    func fetchCoins(completion: @escaping ([Coin]) -> Void) {
        // Construct the URL
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false&x_cg_demo_api_key=\(self.key)"
        guard let url = URL(string: urlString) else { return }
        
        // Fetch request
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for error
            if let error {
                print("DEBUG: Failed with error \(error.localizedDescription)")
                return
            }
            
            // Check we got response
            guard let httpResp = response as? HTTPURLResponse, 200 ... 299  ~= httpResp.statusCode else { return }
            
            // Check we got valid data
            guard let data else { return }
            
            // Convert data to JSON object and to array
            guard let coins = try? JSONDecoder().decode([Coin].self, from: data) else {
                print("DEBUG: Failed to decode coins")
                return
            }
            
            // Pass coins to completion handler
            completion(coins)
        }.resume()
    }
    
    func fetchPrice(coin: String, completion: @escaping (Double) -> Void) {
        // Construct the URL
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(coin)&vs_currencies=usd&x_cg_demo_api_key=\(self.key)"
        guard let url = URL(string: urlString) else { return }
        
        // Fetch request
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for error
            if let error {
                print("DEBUG: Failed with error \(error.localizedDescription)")
                return
            }
            
            // Check we got response
            guard let httpResp = response as? HTTPURLResponse else { return }
            
            // Check we got error code 200
            guard httpResp.statusCode == 200 else { return }
            
            // Check we got valid data
            guard let data else { return }
            
            // Convert data to JSON object and to dictionary
            guard let resp = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else { return }
            
            // Get value from dictionary
            guard let value = resp[coin] as? [String:Double] else { return }
            
            // Get price
            guard let price = value["usd"] else { return }
            
            // Pass price to completion handler
            completion(price)
        }.resume()
    }
}
