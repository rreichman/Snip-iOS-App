//
//  AttributedStringCache.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

public struct AttributedStringCache {
    fileprivate struct CacheEntry: Hashable {
        let underlyingString: String
        
        fileprivate var hashValue: Int {
            return underlyingString.hashValue
        }
    }
    
    fileprivate static var cache = [CacheEntry: NSAttributedString]() {
        didSet {
            assert(Thread.isMainThread)
        }
    }
    
    public static func attributedStringForText(keyString: String) -> NSAttributedString? {
        let key = CacheEntry(underlyingString: keyString)
        return cache[key]
    }
    
    public static func setCacheValue(attributedString: NSAttributedString, for keyString: String) {
        let key = CacheEntry(underlyingString: keyString)
        cache[key] = attributedString
    }
}

private func ==(lhs: AttributedStringCache.CacheEntry, rhs: AttributedStringCache.CacheEntry) -> Bool {
    return lhs.underlyingString == rhs.underlyingString
}
