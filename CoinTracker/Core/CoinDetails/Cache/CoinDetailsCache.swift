//
//  CoinDetailsCache.swift
//  CoinTracker
//
//  Created by Bob Moriasi on 5/1/24.
//

import Foundation

class CoinDetailsCache {
    static let shared = CoinDetailsCache()
    
    private init() {}
    
    private let cache = NSCache<NSString, NSData>()
    
    func set(_ coinDetails: CoinDetails, forKey key: String) {
        /* Encode the details */
        guard let data = try? JSONEncoder().encode(coinDetails) else { return }
        
        /* Set it to cache */
        cache.setObject(data as NSData, forKey: key as NSString)
    }
    
    func get(forKey key: String) -> CoinDetails? {
        /* Get it from cache */
        guard let data = cache.object(forKey: key as NSString) as? Data else {
            return nil
        }
        
        /* Decode the details */
        return try? JSONDecoder().decode(CoinDetails.self, from: data)
    }
}
