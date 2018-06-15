//
//  SnipAuthRequests.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/12/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Crashlytics
import RealmSwift

class SnipAuthRequests {
    static let instance = SnipAuthRequests()
    
    let provider: MoyaProvider<SnipAuthService>.CompatibleType
    let disposeBag: DisposeBag = DisposeBag()
    
    init() {
        self.provider = MoyaProvider<SnipAuthService>()
    }
    
    
    // Returns auth token
    func postLogin(email: String, password: String) -> Single<String> {
        return provider.rx.request(SnipAuthService.login(email: email, pasword: password))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .map { obj -> String in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                if let key = json["key"] as? String {
                    return key
                }
                
                if let error_message = json["non_field_errors"] as? String {
                    throw APIError.badLogin(message: error_message)
                }
                throw APIError.generalError
            }
    }
    
    // Returns auth token
    func postSignUp(email: String, first_name: String, last_name: String, password: String) -> Single<String> {
        return provider.rx.request(SnipAuthService.registration(email: email, password1: password, first_name: first_name, last_name: last_name))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .map { obj -> String in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                if let key = json["key"] as? String {
                    return key
                }
                
                if let error_message_list = json["email"] as? [ String ] {
                    if error_message_list.count > 0 {
                        let msg = error_message_list[0]
                        throw APIError.userAlreadyExists(message: msg)
                    }
                }
                throw APIError.generalError
        }
    }
    
    // Returns auth token
    func postFBToken(facebookToken: String) -> Single<String> {
        return provider.rx.request(SnipAuthService.facbookSync(auth_token: facebookToken))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .map { obj -> String in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                if let key = json["key"] as? String {
                    return key
                }
                throw APIError.generalError
        }
    }
    
    // Returns result message
    func postForgotPassword(email: String) -> Single<String> {
        return provider.rx.request(SnipAuthService.forgotPassword(email: email))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .map { obj -> String in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                if let detail = json["detail"] as? String {
                    return detail
                }
                
                if let _ = json["email"] as? [ String ] {
                    throw APIError.userDoesNotExist
                }
                throw APIError.generalError
        }
    }
    
    func postLogout() -> Single<Bool> {
        return provider.rx.request(SnipAuthService.logout)
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapString()
            .map { response in
                return true
            }
        }
}
