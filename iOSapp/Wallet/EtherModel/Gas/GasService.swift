//
//  GasService.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/8/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya

enum GasService {
    case gasData()
}

extension GasService: TargetType {
    var baseURL: URL {
        return URL(string: "https://f8v6osnp4l.execute-api.us-east-1.amazonaws.com/")!
    }
    
    var path: String {
        return "gas_station"
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
