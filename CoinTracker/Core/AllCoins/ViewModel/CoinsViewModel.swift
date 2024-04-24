//
//  CoinsViewModel.swift
//  CoinTracker
//
//  Created by Bob Moriasi on 4/23/24.
//

import Foundation

class CoinsViewModel: ObservableObject {
    @Published var coin = ""
    @Published var price = ""
    
    private let service = CoinDataService()
    
    init() {
        fetchPrice(coin: "bitcoin")
    }
    
    func fetchPrice(coin: String) {
        service.fetchPrice(coin: coin) { priceFromService in
            DispatchQueue.main.async {
                self.coin = coin.capitalized
                self.price = "$ \(priceFromService)"
            }
        }
    }
}
