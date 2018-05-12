//
//  TransactionError.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/9/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation

enum TransactionError: Error {
    case insufficentBalance(message: String)
    case nonceTooLow
    case invalidAmount
    case keystoreError(message: String)
    case transmitError
    case generalError
    case generalErrorMessage(message: String)
}
