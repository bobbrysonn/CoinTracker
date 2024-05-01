//
//  ContentView.swift
//  CoinTracker
//
//  Created by Bob Moriasi on 4/23/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = CoinsViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.coins) { coin in
                NavigationLink(value: coin) {
                    HStack(spacing: 12) {
                        // Market Rank number
                        Text("\(coin.market_cap_rank)")
                            .foregroundStyle(.gray)
                            .frame(width: 29)
                        
                        // Name and symbol
                        VStack (alignment: .leading, spacing: 4){
                            Text(coin.name)
                                .fontWeight(.semibold)
                            Text(coin.symbol.uppercased())
                                .font(.footnote)
                        }
                    }
                }
            }
            .navigationDestination(for: Coin.self) { coin in
                CoinDetailsView(coinID: coin.id)
            }
            .navigationTitle("Coins")
            .overlay {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
