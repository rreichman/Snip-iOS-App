//
//  AppLinkService.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/28/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya

enum AppLinkService {
    case resolveAppLink(link: URL)
}

extension AppLinkService: TargetType {
    var baseURL: URL {
        switch self {
        case .resolveAppLink(let link):
            return link
        }
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    
}
