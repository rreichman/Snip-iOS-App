//
//  RestUtils.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/12/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
class RestUtils {
    static let snipURLString: String = "https://staging.snip.today"
    //static let snipURL: URL = URL(string: "https://readers-dev-test.snip.today")!
    //static let snipURLString: String = "http://localhost:8000"
    static let apiVersionString: String = "/api/v1"
    
    
    static var baseURL: URL {
        get {
            return URL(string: snipURLString)!
        }
    }
    
    static var versionedApiUrl: URL {
        get {
            return URL(string: "\(snipURLString)\(apiVersionString)")!
        }
    }
    static func buildPostData(params: [ (String, String) ]) -> [ MultipartFormData ] {
        var data: [ MultipartFormData ] = []
        for param in params {
            let value_string = String( param.1 )
            data.append(MultipartFormData(provider: .data(value_string.data(using: .utf8)!), name: param.0))
        }
        return data
    }
}
