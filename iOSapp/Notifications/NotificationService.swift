//
//  SnipLoggerService.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya

enum NotificationService {
    case firebaseToken(registrationToken: String)
    case subscribe(topic: Int)
    case unsubscribe(topic: Int)
}

extension NotificationService: TargetType {
    var baseURL: URL {
        return RestUtils.snipURL
    }
    
    var path: String {
        switch self {
        case .firebaseToken:
            return "/notification/save_token/"
        case .subscribe:
            return "/notification/subscribe/"
        case .unsubscribe:
            return "/notification/unsubscribe/"
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
        case .firebaseToken(let registrationToken):
            let params = [("token", registrationToken), ("platform", "ios")]
            return .uploadMultipart(RestUtils.buildPostData(params: params))
        case .subscribe(let topic):
            let params = [("topic", String(topic))]
            return .uploadMultipart(RestUtils.buildPostData(params: params))
        case .unsubscribe(let topic):
            let params = [("topic", String(topic))]
            return .uploadMultipart(RestUtils.buildPostData(params: params))
        }
    }
    
    var headers: [String : String]? {
        var headers = ["Accept" : "application/json", "Referer": "https://www.snip.today/"]
        if SessionManager.instance.loggedIn {
            if let authToken = SessionManager.instance.authToken {
                headers["Authorization"] = "Token \(authToken)"
                //print("Auth Token: \(authToken)")
            }
        }
        if let session = SessionManager.instance.sessionCookie {
            headers["Cookie"] = "sniptoday=\(session); path=/; domain=.snip.today; HttpOnly;"
        }
        return headers
    }
    
    
}
