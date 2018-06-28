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
    case getUserProfile
    case postVote(post_id: Int, vote_value: Double)
    case postSave(post_id: Int)
    case postReport(post_id: Int, reason: String, param1: String)
    case postComment(post_id: Int, parent_id: Int?, body: String)
    case editComment(post_id: Int, comment_id: Int, body: String)
    case deleteComment(comment_id: Int)
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
            return RestUtils.versionedApiUrl
        }
        
    }
    
    var path: String {
        switch self {
        case .main:
            return "/posts/main/"
        case .postQuery:
            return "/posts/all/"
        case .getUserProfile:
            return "/user/my-profile/"
        case .postVote(let post_id, _):
            return "/posts/post/\(post_id)/action/"
        case .postSave(let post_id):
            return "/posts/post/\(post_id)/action/"
        case .postComment:
            return "/posts/comment/"
        case .editComment(_, let comment_id, _):
            return "/posts/comment/\(comment_id)/"
        case .deleteComment(let comment_id):
            return "/posts/comment/\(comment_id)/"
        case .getSavedSnips:
            return "/posts/saved-posts/"
        case .getLikedSnips:
            return "/posts/my-upvotes/"
        case .postReport(let post_id, _, _):
            return "/posts/post/\(post_id)/report/"
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
        case .editComment:
            return .patch
        case .deleteComment:
            return .delete
        case .postReport:
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
            var params = [("post_id", String(post_id)), ("body", body)]
            if let p_id = parent_id {
                params.append(("parent", String(p_id)))
            }
            return .uploadMultipart(RestUtils.buildPostData(params: params))
        case .editComment(_, _, let body):
            let params = [("body", body)]
            return .uploadMultipart(RestUtils.buildPostData(params: params))
        case .deleteComment:
            return .requestPlain
        case .postReport(_, let reason, _):
            let params = [("reason_list_str", reason)]
            return .uploadMultipart(RestUtils.buildPostData(params: params))
        }
    }
    
    var headers: [String : String]? {
        var headers = ["Accept" : "application/json", "Referer": "https://www.snip.today/"]
        switch self {
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
            if false {
                print("Auth Headers:\n\t Authorization=Token \(SessionManager.instance.authToken)\n\tCookie=\(SessionManager.instance.sessionCookie)")
            }
        }
        //print("cookie: request cookies \(headers)")
        return headers
    }
    
    
}
