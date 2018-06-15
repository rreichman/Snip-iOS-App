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
    case postSave(post_id: Int)
    case postComment(post_id: Int, parent_id: Int?, body: String)
    case getSavedSnips(page: Int?)
    case getLikedSnips(page: Int?)
    case getAppLink(url: String)
}

extension SnipService: TargetType {
    var baseURL: URL {
        switch self {
        case .getPostImage(let imageURL):
            return URL(string: imageURL)!
        case .getAppLink(let url):
            return URL(string: url)!
        default:
            //return URL(string: "https://readers-dev-test.snip.today")!
            return URL(string: "https://www.snip.today")!
        }
        
    }
    
    var path: String {
        switch self {
        case .main:
            return "/main/"
        case .getUserProfile:
            return "/user/my_profile/"
        case .buildUserProfile:
            return "/user/my_profile/"
        case .postVote(let post_id, _):
            return "/action/\(post_id)/"
        case .postSave(let post_id):
            return "/action/\(post_id)/"
        case .postComment:
            return "/comments/publish/"
        case .getSavedSnips:
            return "/saved-posts/"
        case .getLikedSnips:
            return "/my-upvotes/"
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postVote:
            return .post
        case .postSave:
            return .post
        case .postComment:
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
        case .getSavedSnips(let page):
            var params: [String: Any] = [:]
            if let p = page {
                params["page"] = p
            }
            params["page_size"] = 20 //TODO:
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case .getLikedSnips(let page):
            var params: [String: Any] = [:]
            if let p = page {
                params["page"] = p
            }
            params["page_size"] = 20 //TODO:
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case .getAppLink:
            return .requestPlain
        case .getPostImage:
            return .requestPlain
        case .getUserProfile:
            return .requestPlain
        case .buildUserProfile:
            return .requestPlain
        case .postVote(_, let vote_value):
            let action_string = String("vote")
            let vote_val_string = String("\(vote_value)")
            let action = MultipartFormData(provider: .data(action_string.data(using: .utf8)!), name: "action")
            let param1 = MultipartFormData(provider: .data(vote_val_string.data(using: .utf8)!), name: "param1")
            return .uploadMultipart([action, param1])
        case .postSave:
            let action_string = String("save")
            let action = MultipartFormData(provider: .data(action_string.data(using: .utf8)!), name: "action")
            return .uploadMultipart([action])
        case .postComment(let post_id, let parent_id, let body):
            let post_id_name = String("post_id")
            let post_id_string = String(post_id)
            let body_name = String("body")
            let post_id = MultipartFormData(provider: .data(post_id_string.data(using: .utf8)!), name: post_id_name)
            let body = MultipartFormData(provider: .data(body.data(using: .utf8)!), name: body_name)
            var params = [post_id, body]
            if let p_id = parent_id {
                let parent_id_name = String("parent")
                let parent_id_string = String(p_id)
                let parent = MultipartFormData(provider: .data(parent_id_string.data(using: .utf8)!), name: parent_id_name)
                params.insert(parent, at: 1)
            }
            return .uploadMultipart(params)
        }
    }
    
    var headers: [String : String]? {
        var headers = ["Accept" : "application/json", "Referer": "https://www.snip.today/"]
        switch self {
        case .buildUserProfile(let authToken):
            headers["Authorization"] = "Token \(authToken)"
            break
        case .getPostImage:
            return [:]
        default:
            if SessionManager.instance.loggedIn {
                if let authToken = SessionManager.instance.authToken {
                    headers["Authorization"] = "Token \(authToken)"
                    //print("Auth Token: \(authToken)")
                }
            }
            if let session = SessionManager.instance.sessionCookie {
                headers["Cookie"] = "sniptoday=\(session); path=/; domain=.snip.today; HttpOnly;"
            }
            if true {
                print("Auth Headers:\n\t Authorization=Token \(SessionManager.instance.authToken)\n\tCookie=\(SessionManager.instance.sessionCookie)")
            }
        }
        //print("cookie: request cookies \(headers)")
        return headers
    }
    
    
}
