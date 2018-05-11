//
//  TickerService.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/8/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya

enum TickerService {
    case snipEthExchange()
    case ethUsdExchange()
}

extension TickerService: TargetType {
    var baseURL: URL {
        switch self {
        case .snipEthExchange():
            return URL(string: "https://api.qryptos.com")!
        case .ethUsdExchange():
            return URL(string: "https://api.coinmarketcap.com")!
        }
    }
    
    var path: String {
        switch self {
        case .snipEthExchange():
            return "/products/100"
        case .ethUsdExchange():
            return "/v1/ticker/ethereum"
        }
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
        return ["Accept": "application/json"]
    }
    
    
}
