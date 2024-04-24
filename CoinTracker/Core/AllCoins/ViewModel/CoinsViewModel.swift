//
//  CoinsViewModel.swift
//  CoinTracker
//
//  Created by Bob Moriasi on 4/23/24.
//

import Foundation

class CoinsViewModel: ObservableObject {
    @Published var coins = [Coin]()
    
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
}
