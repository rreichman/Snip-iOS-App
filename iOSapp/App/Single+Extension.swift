//
//  Single+Extension.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import RxSwift

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    public func mapServerErrors() -> Single<Response> {
        return map { response -> Response in
            if response.statusCode >= 500 {
                throw APIError.serverError(errorMessage: response.description, code: response.statusCode, response: response)
            } else if response.statusCode >= 400 {
                if response.statusCode == 401 {
                    print("Recv Status 401, clearing auth token")
                    SessionManager.instance.logout()
                    throw APIError.badLogin(message: "Bad auth token")
                }
                throw APIError.requestError(errorMessage: response.description, code: response.statusCode, response: response)
            }
            return response
        }
    }
}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    public func cookieIntercept() -> Single<Response> {
        return map { response -> Response in
            guard
                let headers = response.response?.allHeaderFields as? [String: String],
                let url = response.response?.url else { return response }
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
            let snipCookies = cookies.filter({ (cookie) -> Bool in
                cookie.name == "sniptoday"
            })
            if snipCookies.count > 0 {
                let snip_cookie = snipCookies[0]
                SessionManager.instance.sessionCookie = snip_cookie.value
                //print("Cookie intercepted and stored \(snip_cookie.value) ")
            }
            return response
        }
    }
}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    public func mapSnipRequest() -> Single<Response> {
        return mapServerErrors()
                .cookieIntercept()
    }
}
