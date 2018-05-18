//
//  SnipService.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya

enum SnipService {
    case main
    case getPostImage(imageURL: String)
}

extension SnipService: TargetType {
    var baseURL: URL {
        switch self {
        case .main:
            return URL(string: "https://www.snip.today/")!
        case .getPostImage(let imageURL):
            return URL(string: imageURL)!
        }
        
    }
    
    var path: String {
        switch self {
        case .main:
            return "/main"
        case .getPostImage:
            return ""
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .main:
            return .requestPlain
        case .getPostImage:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Accept" : "application/json"]
    }
    
    
}
