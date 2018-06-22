//
//  SnipLoggerService.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya

enum SnipLoggerService {
    case deviceLog(deviceID: String)
    
}

extension SnipLoggerService: TargetType {
    var baseURL: URL {
        return RestUtils.snipURL
    }
    
    var path: String {
        switch self {
        case .deviceLog:
            return "/user/device_log/"
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
        case .deviceLog(let deviceID):
            let os_version = UIDevice.current.systemVersion
            var app_version = ""
            if let infoDictionary = Bundle.main.infoDictionary, let version = infoDictionary["CFBundleShortVersionString"] as? String {
                app_version = version
            }
            let params = [("device_id", deviceID), ("os", "ios"), ("os_version", os_version), ("app_version", app_version)]
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
