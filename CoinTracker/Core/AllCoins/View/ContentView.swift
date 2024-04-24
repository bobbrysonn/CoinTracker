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
        VStack {
            ForEach(viewModel.coins) { coin in
                Text(coin.name)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
