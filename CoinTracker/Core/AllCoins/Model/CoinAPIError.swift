//
//  CoinAPIError.swift
//  CoinTracker
//
//  Created by Bob Moriasi on 4/25/24.
//

import Foundation

enum CoinAPIError: Error {
    case datataskExecutionFailed(localizedDescription: String)
    case invalidData
    case invalidStatusCode(statusCode: Int)
    case jsonParsingFailed
    case requestFailed(description: String)
}
