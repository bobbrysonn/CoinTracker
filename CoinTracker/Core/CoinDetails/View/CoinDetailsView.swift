//
//  CoinDetailsView.swift
//  CoinTracker
//
//  Created by Bob Moriasi on 4/29/24.
//

import SwiftUI

struct CoinDetailsView: View {
    @ObservedObject var viewModel: CoinDetailsViewModel
    
    init(coinID: String) {
        self.viewModel = CoinDetailsViewModel(coinID: coinID)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let coinDetails = viewModel.details {
                /* Name of the coin */
                Text("\(coinDetails.name)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                /* Coin symbol */
                Text("\(coinDetails.symbol.uppercased())")
                    .font(.footnote)
                
                /* Description */
                Text("\(coinDetails.description.text)")
                    .font(.footnote)
                    .padding(.vertical)
            }
        }
        .task {
            await viewModel.fetchCoinDetails()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

