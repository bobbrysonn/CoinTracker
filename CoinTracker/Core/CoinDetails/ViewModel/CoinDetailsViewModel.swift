//
//  CoinDetailsViewModel.swift
//  CoinTracker
//
//  Created by Bob Moriasi on 4/29/24.
//

import Foundation

class CoinDetailsViewModel: ObservableObject {
    @Published var details: CoinDetails?
    @Published var errorMessage: String?
    
    private let service: CoinServiceProtocol
    private let coinID: String
    
    init(coinID: String, service: CoinServiceProtocol) {
        // Initialize the coinID
        self.coinID = coinID
        
        /* Initialize service injected from CoinDetailsView <- ContentView <- CoinTrackerApp */
        self.service = service
    }

    // Fetch all coins
    @MainActor func fetchCoinDetails() async {
        do {
            self.details = try await service.fetchCoinDetails(coinID: coinID)
        } catch let error {
            if let error = error as? CoinAPIError {
                self.errorMessage = error.customDescription
            } else {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
