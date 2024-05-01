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
    
    var customDescription: String {
        switch self {
        case let .datataskExecutionFailed(reason):
            return "Executing the data task failed: \(reason)"
        case .invalidData:
            return "The data is invalid"
        case let .invalidStatusCode(statusCode):
            return "Forbidded status error code: \(statusCode)"
        case .jsonParsingFailed:
            return "Parsing JSON failed"
        case .requestFailed:
            return "Carrying out the request failed"
        }
    }
}
