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
                } else if (response.statusCode == 403) {
                    return response
                }
                var message = try? response.mapString()
                if message == nil {
                    message = "Server error"
                }
                throw APIError.requestError(errorMessage: message!, code: response.statusCode, response: response)
            }
            return response
        }
    }
    
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
    
    public func mapSnipRequest() -> Single<Response> {
        return mapServerErrors()
            .cookieIntercept()
    }
    
    public func mapJSONWithResponse() -> Single<(Any, Response)> {
        return map { response -> (Any, Response) in
            return (try! response.mapJSON(), response)
        }
    }
}

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Any {
    public func mapSnipAuthErrors() -> Single<Any> {
        return map { obj -> Any in
            guard let json = obj as? [String: Any] else {
                return obj
            }
            
            if let email_errors = json["email"] as? [ String ] {
                let error_message = SnipAuthRequests.parseErrorMessageList(errors: email_errors)
                throw APIError.authFieldError(field: "email", message: error_message)
            }
            
            if let password_errors = json["password1"] as? [ String ] {
                let error_message = SnipAuthRequests.parseErrorMessageList(errors: password_errors)
                throw APIError.authFieldError(field: "passsword", message: error_message)
            }
            
            if let error_message_list = json["non_field_errors"] as? [ String ] {
                let error_message = SnipAuthRequests.parseErrorMessageList(errors: error_message_list)
                throw APIError.authNonFieldError(message: error_message)
            }
            
            return obj
        }
    }
}
