//
//  SnipService.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya

enum SnipService {
    case main
    case postQuery(params: [String: Any], page: Int?)
    case getPostImage(imageURL: String)
    case buildUserProfile(authToken: String)
    case getUserProfile
    case postVote(post_id: Int, vote_value: Double)
}

extension SnipService: TargetType {
    var baseURL: URL {
        switch self {
        case .getPostImage(let imageURL):
            return URL(string: imageURL)!
        default:
            return URL(string: "https://www.snip.today")!
        }
        
    }
    
    var path: String {
        switch self {
        case .main:
            return "/main"
        case .getUserProfile:
            return "/user/my_profile/"
        case .buildUserProfile:
            return "/user/my_profile/"
        case .postVote(let post_id, _):
            return "/action/\(post_id)/"
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postVote:
            return .post
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .main:
            return .requestPlain
        case .postQuery(var params, let page):
            if let p = page {
                params["page"] = p
            }
            params["page_size"] = 20 //TODO:
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case .getPostImage:
            return .requestPlain
        case .getUserProfile:
            return .requestPlain
        case .buildUserProfile:
            return .requestPlain
        case .postVote(_, let vote_value):
            let body: [String: Any] = ["action": "vote", "param1": "\(vote_value)"]
            let action_string = String("action")
            let vote_val_string = String("\(vote_value)")
            let action = MultipartFormData(provider: .data(action_string.data(using: .utf8)!), name: "action")
            let param1 = MultipartFormData(provider: .data(vote_val_string.data(using: .utf8)!), name: "param1")
            return .uploadMultipart([action, param1])
        }
    }
    
    var headers: [String : String]? {
        var headers = ["Accept" : "application/json"]
        switch self {
        case .buildUserProfile(let authToken):
            headers["Authorization"] = "Token \(authToken)"
        default:
            if SessionManager.instance.loggedIn {
                if let authToken = SessionManager.instance.authToken {
                    
                    headers["Authorization"] = "Token \(authToken)"
                    
                }
            }
            if let session = SessionManager.instance.sessionCookie {
                headers["cookie"] = "sniptoday=\(session);"
            }
        }
        print("cookie: request cookies \(headers)")
        return headers
    }
    
    
}
