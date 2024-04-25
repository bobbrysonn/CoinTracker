//
//  CoinsViewModel.swift
//  CoinTracker
//
//  Created by Bob Moriasi on 4/23/24.
//

import Foundation

class CoinsViewModel: ObservableObject {
    @Published var coins = [Coin]()
    @Published var errorMessage: String?
    
    private let service = CoinDataService()
    
    init() {
        fetchCoins()
    }

    // Fetch all coins
    func fetchCoins() {
        service.fetchCoins { coinsFromService in
            DispatchQueue.main.async {
                self.coins = coinsFromService
            }
        }
    }
    
    // Fetch all coins
    func fetchCoinsWithResult() {
        service.fetchCoinsWithResult { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coins):
                    self?.coins = coins
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
