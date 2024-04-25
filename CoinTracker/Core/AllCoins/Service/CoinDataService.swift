//
//  CoinDataService.swift
//  CoinTracker
//
//  Created by Bob Moriasi on 4/23/24.
//

import Foundation

class CoinDataService {
    // API KEY
    let key = "CG-zwRnUM8eRJTXCsWJdyrsfz6E"
    
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
