//
//  EtherscanService.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/2/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import TrustCore
import TrustKeystore
import Moya

enum EtherscanService {
    //case sendRawTransaction(raw: String)
    case getTransactionList(address: String)
    case getInternalTransactions(address: String)
}


extension EtherscanService: TargetType {
    var api_key: String {
        return NetworkSettings.getNetwork().etherscan_api
    }
    
    var contract_address: String {
        return NetworkSettings.getNetwork().contract_address
    }
    var baseURL: URL {
        return URL(string: NetworkSettings.getNetwork().etherscan_url)!
    }
    
    var path: String {
        return "/api"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "pass".utf8Encoded
    }
    
    var task: Task {
        switch self {
        case .getInternalTransactions(let address):
            let strip_short_prefix = String(address[address.index(address.startIndex, offsetBy:2)...])
            let address_data = "0x000000000000000000000000\(strip_short_prefix)"
            return .requestParameters(parameters:
                ["module" : "logs",
                 "action" : "getLogs",
                 "fromBlock" : "0",
                 "toBlock" : "latest",
                 "apikey" : api_key,
                 "address" : contract_address,
                 "topic2" : address_data],
          encoding: URLEncoding.queryString)
        case .getTransactionList(let address):
            return .requestParameters(parameters:
                ["address" : address,
                 "module" : "account",
                 "action" : "txlist",
                 "sort" : "asc",
                 "apikey" : api_key], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}

private extension String {
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
