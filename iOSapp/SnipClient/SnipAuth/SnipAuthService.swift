//
//  SnipAuthService.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/12/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya

enum SnipAuthService {
    case login(email: String, pasword: String)
    case registration(email: String, password1: String, first_name: String, last_name: String)
    case forgotPassword(email: String)
    case facbookSync(auth_token: String)
    case logout
}

extension SnipAuthService: TargetType {
    var baseURL: URL {
        return RestUtils.snipURL
    }
    
    var path: String {
        switch self {
        case .login:
            return "/rest-auth/login/"
        case .registration:
            return "/rest-auth/registration/"
        case .forgotPassword:
            return "/rest-auth/password/reset/"
        case .facbookSync:
            return "/rest-auth/facebook/"
        case .logout:
            return "/rest-auth/logout/"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .login(let email, let password):
            let params = [ ("email", email), ("password", password)]
            return .uploadMultipart(RestUtils.buildPostData(params: params))
        case .registration(let email, let password1, let first_name, let last_name):
            let params = [ ("email", email), ("password1", password1), ("first_name", first_name), ("last_name", last_name) ]
            return .uploadMultipart(RestUtils.buildPostData(params: params))
        case .forgotPassword(let email):
            let params = [ ("email", email) ]
            return .uploadMultipart(RestUtils.buildPostData(params: params))
        case .facbookSync(let auth_token):
            let params = [ ("access_token", auth_token) ]
            return .uploadMultipart(RestUtils.buildPostData(params: params))
        case .logout:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        var headers: [String: String] = ["Accept" : "application/json"]
        if let session = SessionManager.instance.sessionCookie {
            headers["Cookie"] = "sniptoday=\(session); path=/; domain=.snip.today; HttpOnly;"
        }
        if SessionManager.instance.loggedIn {
            if let authToken = SessionManager.instance.authToken {
                headers["Authorization"] = "Token \(authToken)"
            }
        }
        if false {
            print("Auth Headers:\n\t Authorization=Token \(SessionManager.instance.authToken)\n\tCookie=\(SessionManager.instance.sessionCookie)")
        }
        
        return headers
    }
    
    
}
