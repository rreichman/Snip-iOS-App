//
//  EtherscanRequests.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RxSwift
import Moya


class EtherscanRequest {
    static let instance: EtherscanRequest = EtherscanRequest()
    
    let provider: MoyaProvider<EtherscanService>
    init() {
        self.provider = MoyaProvider<EtherscanService>()
    }
    
    func getTransactions(for address:String) -> Single<[Transaction]> {
        return provider.rx.request(EtherscanService.getTransactionList(address: address))
            .subscribeOn(SingleBackgroundThread.scheduler)
            .observeOn(MainScheduler.instance)
            .mapServerErrors()
            .mapJSON()
            .map { json -> [Transaction] in
                guard let obj = json as? [String: Any] else { throw SerializationError.invalid("invalid response json", json)}
                let transaction_list = try Transaction.parseEtherscanTransactionList(json: obj)
                return transaction_list
        }
            
    }
}
