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
                    SessionManager.instance.authToken = nil
                    SessionManager.instance.currentLoginUsername = nil
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
            //print("cookie: debug request headers \(String(describing: response.request?.allHTTPHeaderFields))")
            //print("cookie: response headers\(headers)")
            if snipCookies.count > 0 {
                let snip_cookie = snipCookies[0]
                //print("old cookie: \(String(describing: SessionManager.instance.sessionCookie)) new cookie: \(snip_cookie.value)")
                //                  sniptoday=6dd072xzt0trdm9qzhmxk5ye79v1gy0f; Domain=.snip.today; expires=Wed, 22-Aug-2018 00:09:06 GMT; HttpOnly; Max-Age=7776000; Path=/
                //let cookieString = "sniptoday=6dd072xzt0trdm9qzhmxk5ye79v1gy0f; Domain=.snip.today; Path=/"
                SessionManager.instance.sessionCookie = snip_cookie.value
            }
            
            //print(cookies)
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
