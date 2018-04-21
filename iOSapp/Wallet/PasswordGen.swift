//
//  PasswordGen.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/13/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Security

struct PasswordGen {
    
    static func generateRandomPassword() -> String {
        return PasswordGen.generateRandom(bytes: 32)
    }
    
    static func generateRandom(bytes: Int) -> String {
        var rBytes = [UInt8](repeating: 0, count: bytes)
        let _ = SecRandomCopyBytes(kSecRandomDefault, bytes, &rBytes)
        return rBytes.map({ String(format: "%02hhx", $0) }).joined(separator: "")
    }
}
