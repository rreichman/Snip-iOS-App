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
    static let snipURL: URL = URL(string: "https://www.snip.today")!
    //static let snipURL: URL = URL(string: "https://readers-dev-test.snip.today")!
    
    static func buildPostData(params: [ (String, String) ]) -> [ MultipartFormData ] {
        var data: [ MultipartFormData ] = []
        for param in params {
            let value_string = String( param.1 )
            data.append(MultipartFormData(provider: .data(value_string.data(using: .utf8)!), name: param.0))
        }
        return data
    }
}
