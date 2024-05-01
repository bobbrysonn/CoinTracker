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
    
    private let service = CoinDataService()
    private let coinID: String
    
    init(coinID: String) {
        // Initialize the coinID
        self.coinID = coinID
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
