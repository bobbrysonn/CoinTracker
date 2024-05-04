//
//  CoinTrackerTests.swift
//  CoinTrackerTests
//
//  Created by Bob Moriasi on 5/2/24.
//

import XCTest

@testable import CoinTracker

final class CoinTrackerTests: XCTestCase {
    func testJSONDecodeCoinsIntoArray() throws {
        do {
            let coins = try JSONDecoder().decode([Coin].self, from: testCoinsData) // Try decoding data to array
            
            XCTAssertFalse(coins.isEmpty)                                          // Make sure it succeeded
            XCTAssertEqual(coins.count, 20)                                        // Check that we got 20 coins
            XCTAssertEqual(coins, coins.sorted(by: { $0.market_cap_rank < $1.market_cap_rank }))
        } catch let error {
            XCTFail("\(error.localizedDescription)")
        }
    }
}
  
