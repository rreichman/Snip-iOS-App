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
    
    let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
        do {
            var request: URLRequest = try endpoint.urlRequest()
            request.httpShouldHandleCookies = false
            done(.success(request))
        } catch {
            done(.failure(MoyaError.underlying(error, nil)))
        }
    }
    
    let provider: MoyaProvider<SnipAuthService>.CompatibleType
    let disposeBag: DisposeBag = DisposeBag()
    
    init() {
        self.provider = MoyaProvider<SnipAuthService>(requestClosure: requestClosure)
    }
    
    
    // Returns auth token
    func postLogin(email: String, password: String) -> Single<String> {
        return provider.rx.request(SnipAuthService.login(email: email, pasword: password))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .mapSnipAuthErrors()
            .map { obj -> String in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                if let key = json["key"] as? String {
                    return key
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
            .mapSnipAuthErrors()
            .map { (obj) -> String in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                if let key = json["key"] as? String {
                    return key
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
            .mapSnipAuthErrors()
            .map { obj -> String in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                if let detail = json["detail"] as? String {
                    return detail
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
    
    public static func parseErrorMessageList(errors: [ String ] ) -> String {
        var errors_list = errors
        //errors_list.append("Test Error Message")
        var error_message = ""
        for msg in errors_list {
            error_message += "\(msg)\n"
        }
        if errors_list.count > 0 {
            error_message = String(error_message[error_message.startIndex...error_message.index(error_message.endIndex, offsetBy: -2)])
        }
        return error_message
    }
}
