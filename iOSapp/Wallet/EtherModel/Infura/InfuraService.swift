//
//  InfuraService.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import TrustCore
import TrustKeystore
import Moya

enum InfuraService {
    case ethCall(params: String)
    case ethCallPost(params: String)
    case ethGetBalance(address: String)
    case ethSendRawTransaction(data: Data)
    case ethGetTransactionCount(address: String)
}


extension InfuraService: TargetType {
    var api_key: String {
        return NetworkSettings.rinkeby.infura_api_key
    }
    
    var ethersacn_api_key: String {
        return "ZYZSJ92PB9JETQTT1JZ4U9K89ZYDXT2F3T"
    }
    
    var contract_address: String {
        return NetworkSettings.rinkeby.contract_address
    }
    
    var baseURL: URL {
        switch self {
        case .ethSendRawTransaction:
            return etherscanBaseURL
        default:
            return URL(string: NetworkSettings.rinkeby.infura_url)!
        }
    }
    
    var etherscanBaseURL: URL {
        return URL(string: NetworkSettings.rinkeby.etherscan_url)!
    }
    
    var path: String {
        var base = "/v1/jsonrpc/rinkeby/"
        switch self {
        case .ethCall:
            base += "eth_call"
        case .ethCallPost:
            base += "eth_call"
        case .ethGetBalance:
            base += "eth_getBalance"
        case .ethSendRawTransaction:
            return "/api"
            //return "/v1/jsonrpc/rinkeby"
        case .ethGetTransactionCount:
            base += "eth_getTransactionCount"
        }
        return base
    }
    
    var method: Moya.Method {
        switch self {
        case .ethCall:
            return .get
        case .ethCallPost:
            return .post
        case .ethGetBalance:
            return .get
        case .ethSendRawTransaction:
            return .post
        case .ethGetTransactionCount:
            return.get
        }
    }
    
    var sampleData: Data {
        return "pass".utf8Encoded
    }
    
    var task: Task {
        switch self {
        case .ethCall(let params):
            return .requestParameters(parameters:
            ["params": params,
            "token": api_key], encoding: URLEncoding.queryString)
        case .ethCallPost(let params):
            return .requestParameters(parameters:
                ["params": params,
                 "token": api_key], encoding: URLEncoding.queryString)
        case .ethGetBalance(let address):
            return .requestParameters(parameters:
            ["params": "[\"\(address)\", \"latest\"]",
                "token": api_key], encoding: URLEncoding.queryString)
        /*
        case .ethSendRawTransaction(let data):
            let body = RawTransactionBody(jsonrpc: "2.0", method: "eth_sendRawTransaction", params: [ WalletUtils.dataToHexString(data: data, addPrefix: true)], id: 1)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try! encoder.encode(body)
            print(String(data: data, encoding: .utf8)!)
            
            return Task.requestData(data)
            */
        case .ethSendRawTransaction(let data):
            return .requestParameters(parameters: ["module" : "proxy", "action": "eth_sendRawTransaction", "hex" : WalletUtils.dataToHexString(data: data), "apikey": ethersacn_api_key], encoding: URLEncoding.queryString)
        case .ethGetTransactionCount(let address):
            return .requestParameters(parameters: ["params": "[\"\(address)\", \"latest\"]", "token": api_key], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .ethSendRawTransaction:
            return [:]
        default:
            return ["Content-Type": "application/json",
                    "Accept": "application/json"]
        }
    }
    
    
}

struct RawTransactionBody: Encodable {
    let jsonrpc: String
    let method: String
    let params: [ String ]
    let id: Int
}
private extension String {
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
