//
//  InfuraRequests.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/7/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import BigInt
import RxSwift
import TrustCore

class InfuraRequests {
    static let instance = InfuraRequests()
    
    let provider: MoyaProvider<InfuraService>
    init() {
        self.provider = MoyaProvider<InfuraService>()
    }
    
    func getTokenBalance(contract addr: String, wallet walletAddress: String) -> Single<BigInt> {
        let encodedCall = ERC20Encoder.encodeBalanceOf(address: Address(string: walletAddress)!)
        let functionHash = WalletUtils.dataToHexString(data: encodedCall, addPrefix: true)
        
        let params = """
        [ { "to": "\(addr)", "data": "\(functionHash)" }, "latest" ]
        """
        
        
        return provider.rx.request(InfuraService.ethCall(params: params))
            .subscribeOn(SingleBackgroundThread.scheduler)
            .mapServerErrors()
            .mapJSON()
            .map { obj -> BigInt in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("Invalid json eth_call", obj) }
                guard let result = json["result"] as? String else { throw SerializationError.missing("result of eth_call") }
                if result.count < 3 {
                    throw SerializationError.invalid("invalid result lenght", result)
                }
                let strip_prefix = result[result.index(result.startIndex, offsetBy:2)...]
                guard let int = BigInt(strip_prefix, radix: 16) else { return BigInt(0) }
                return int
        }
    }
    
    func getEthBalance(wallet address: String) -> Single<BigInt> {
       return provider.rx.request(InfuraService.ethGetBalance(address: address))
        .subscribeOn(SingleBackgroundThread.scheduler)
        .mapServerErrors()
        .mapJSON()
        .map { obj -> BigInt in
            guard let json = obj as? [String: Any] else { throw SerializationError.invalid("invalid json", obj)}
            guard let result = json["result"] as? String else { throw SerializationError.missing("result") }
            if result.count < 3 {
                throw SerializationError.invalid("invalid result lenght", result)
            }
            let strip_prefix = result[result.index(result.startIndex, offsetBy:2)...]
            guard let int = BigInt(strip_prefix, radix: 16) else { return BigInt(0) }
            return int
        }
    }
    
    func sendRawTransaction(raw tx: Data) -> Single<String> {
        return provider.rx.request(InfuraService.ethSendRawTransaction(data: tx))
            .subscribeOn(SingleBackgroundThread.scheduler)
            .do(onSuccess: { resp in
                print(resp.request!.description)
            })
            .mapServerErrors()
            .mapJSON()
            .map { obj -> String in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("invalid json", obj)}
                guard let result = json["result"] as? String else {
                    
                    if let error = json["error"] as? String {
                        if error == "nonce too low" {
                            throw TransactionError.nonceTooLow
                        } else {
                            throw TransactionError.generalError
                        }
                    }
                    if let error = json["error"] as? [String: Any] {
                        guard let message = error["message"] as? String else { throw TransactionError.generalError }
                        if message == "nonce too low" {
                            throw TransactionError.nonceTooLow
                        } else {
                            throw TransactionError.generalErrorMessage(message: message)
                        }
                    }
                    throw TransactionError.generalError
                }
                if result.count == 0 {
                    throw SerializationError.invalid("invalid result lenght", result)
                }
                return result
        }
    }
    
    func getTransactionCount(address: String) -> Single<Int> {
        return provider.rx.request(InfuraService.ethGetTransactionCount(address: address))
            .subscribeOn(SingleBackgroundThread.scheduler)
            .mapServerErrors()
            .mapJSON()
            .map { obj -> Int in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("invalid json", obj)}
                guard let result = json["result"] as? String else { throw SerializationError.missing("result") }
                if result.count < 3 {
                    throw SerializationError.invalid("invalid result lenght", result)
                }
                let strip_prefix = result[result.index(result.startIndex, offsetBy:2)...]
                guard let int = Int(strip_prefix, radix: 16) else { return 0 }
                return int
        }
    }
    
}
