//
//  APIError.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya

enum APIError: Error {
    case badMessage(message: String)
    case badStatus(message: String)
    case serverError(errorMessage: String, code: Int, response: Response)
    case requestError(errorMessage: String, code: Int, response: Response)
    case generalAuthError(message: String)
    case authFieldError(field: String, message: String)
    case authNonFieldError(message: String)
    case badLogin(message: String)
    case generalError
    case unableToResolveAppLink(of: URL)
}
