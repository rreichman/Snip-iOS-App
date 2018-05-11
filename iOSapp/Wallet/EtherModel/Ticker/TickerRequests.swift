//
//  TickerRequests.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/8/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import BigInt

class TickerRequests {
    static let instance = TickerRequests()
    
    let provider: MoyaProvider<TickerService>
    init() {
        self.provider = MoyaProvider<TickerService>()
    }
    
    func getSnipEthExchange() -> Single<Double> {
        return provider.rx.request(TickerService.snipEthExchange())
            .subscribeOn(SingleBackgroundThread.scheduler)
            .mapServerErrors()
            .mapJSON()
            .map { obj -> Double in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("invalid json", obj) }
                guard let market_bid = json["market_bid"] as? Double else { throw SerializationError.invalid("snip exchange", json)}
                return market_bid
            }
    }
    
    func getEthUsdExchange() -> Single<Double> {
        return provider.rx.request(TickerService.ethUsdExchange())
            .subscribeOn(SingleBackgroundThread.scheduler)
            .mapServerErrors()
            .do(onSuccess: { resp in
                print(resp)
            })
            .mapJSON()
            .map { obj -> Double in
                guard let json_array = obj as? [ [String: Any] ] else { throw SerializationError.invalid("invalid json", obj) }
                if json_array.count == 0 {
                    throw SerializationError.invalid("stupid server response", obj)
                }
                let json = json_array[0]
                guard let market_bid_string = json["price_usd"] as? String else { throw SerializationError.invalid("eth exchange", json)}
                guard let market_bid = Double(market_bid_string) else { throw SerializationError.invalid("invalid double as string", market_bid_string)}
                return market_bid
        }
    }

}
