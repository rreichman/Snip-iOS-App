//
//  GasRequests.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/8/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import BigInt

class GasRequests {
    static let instance = GasRequests()
    
    let provider: MoyaProvider<GasService>
    init() {
        self.provider = MoyaProvider<GasService>()
    }
    
    func getGasData() -> Single<GasData> {
        return provider.rx.request(GasService.gasData())
            .subscribeOn(SingleBackgroundThread.scheduler)
            .mapServerErrors()
            .mapJSON()
            .map { obj -> GasData in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("gas data", obj) }
                let data = try GasData.parseJson(of: json)
                return data
        }
    }
    
    
}
