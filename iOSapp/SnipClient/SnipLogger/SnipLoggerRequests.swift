//
//  SnipLoggerRequests.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Crashlytics
import RealmSwift

class SnipLoggerRequests {
    static let instance = SnipLoggerRequests()
    
    let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
        do {
            var request: URLRequest = try endpoint.urlRequest()
            request.httpShouldHandleCookies = false
            done(.success(request))
        } catch {
            done(.failure(MoyaError.underlying(error, nil)))
        }
    }
    
    let provider: MoyaProvider<SnipLoggerService>.CompatibleType
    let disposeBag: DisposeBag = DisposeBag()
    init() {
        self.provider = MoyaProvider<SnipLoggerService>(requestClosure: requestClosure)
    }
    
    func postDeviceID() {
        let uuid: UUID? = UIDevice.current.identifierForVendor
        let uuid_string = (uuid == nil ? "" : uuid!.uuidString)
        provider.rx.request(SnipLoggerService.deviceLog(deviceID: uuid_string))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .subscribe(onSuccess: { (response) in
                print("Logged device id: \(uuid_string)")
            }) { (err) in
                print("Error logging device id: \(uuid_string)")
                Crashlytics.sharedInstance().recordError(err)
            }
            .disposed(by: self.disposeBag)
    }
    
}
