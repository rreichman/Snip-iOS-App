//
//  APIError.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation


enum APIError: Error {
    case badMessage(message: String)
    case badStatus(message: String)
    case serverError(errorMessage: String, code: Int)
    case requestError(errorMessage: String, code: Int)
}
