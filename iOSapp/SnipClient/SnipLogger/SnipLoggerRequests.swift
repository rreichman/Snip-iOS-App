//
//  SnipLoggerRequests.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Crashlytics
import RealmSwift

enum CommentInteraction {
    case opened
    case submit
    case edit
    case delete
}

class SnipLoggerRequests {
    static let instance = SnipLoggerRequests()
    
    let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
        do {
            var request: URLRequest = try endpoint.urlRequest()
            request.httpShouldHandleCookies = false
            done(.success(request))
        } catch {
            done(.failure(MoyaError.underlying(error, nil)))
        }
    }
    
    let provider: MoyaProvider<SnipLoggerService>.CompatibleType
    let disposeBag: DisposeBag = DisposeBag()
    init() {
        self.provider = MoyaProvider<SnipLoggerService>(requestClosure: requestClosure)
    }
    
    func postDeviceID() {
        let uuid: UUID? = UIDevice.current.identifierForVendor
        let uuid_string = (uuid == nil ? "" : uuid!.uuidString)
        provider.rx.request(SnipLoggerService.deviceLog(deviceID: uuid_string))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .subscribe(onSuccess: { (response) in
                print("Logged device id: \(uuid_string)")
            }) { (err) in
                print("Error logging device id: \(uuid_string)")
                Crashlytics.sharedInstance().recordError(err)
            }
            .disposed(by: self.disposeBag)
    }
    
    func logCategoryView(categoryName: String, fromDiscover: Bool) {
        let action = (fromDiscover ? "category_from_discover" : "category_from_feed")
        postActionParam(action: action, param: categoryName)
    }
    
    func logAuthorProfileView(authorUserName: String) {
        postActionParam(action: "author_profile", param: authorUserName)
    }
    
    func logDiscoverTabView() {
        postActionParam(action: "discover", param: "viewed")
    }
    
    func logProfileTabViewed(redirectedToLoginSingup: Bool) {
        postActionParam(action: "profile", param: (redirectedToLoginSingup ? "redirect_to_login" : "viewed"))
    }
    
    func logSavedPostsViewed() {
        postActionParam(action: "saved_snips", param: "opened")
    }
    
    func logFavoritePostsViewed() {
        postActionParam(action: "favorite_snips", param: "opened")
    }
    
    func logPostDeepLink(postId: Int, fromNotification: Bool) {
        postActionParam(action: (fromNotification ? "notification_deeplinking" : "deeplinking"), param: String(postId))
    }
    
    func logSingup(fromFacebook: Bool) {
        postActionParam(action: "signup", param: (fromFacebook ? "facebook" : "basic"))
    }
    
    func logSignIn(fromFacebook: Bool) {
        postActionParam(action: "signin", param: (fromFacebook ? "facebook" : "basic"))
    }
    
    func logNewWallet(imported: Bool) {
        postActionParam(action: (imported ? "importWallet" : "createWallet"), param: "")
    }
    
    func logPostView(postId: Int) {
        postPostAction(postId: postId, action: "viewed", param: "")
    }
    
    func logImageExpanded(postId: Int) {
        postPostAction(postId: postId, action: "image", param: "clicked")
    }
    
    func logPostShared(postId: Int) {
        postPostAction(postId: postId, action: "share", param: "")
    }
    
    func logPostCommentIteraction(postId: Int, interaction: CommentInteraction) {
        var param: String!
        switch interaction {
        case .delete:
            param = "deleted"
        case .edit:
            param = "edited"
        case .opened:
            param = "opened"
        case .submit:
            param = "submit"
        }
        postPostAction(postId: postId, action: "comment", param: param)
    }
    
    func logPostReadMore(postId: Int) {
        postPostAction(postId: postId, action: "readmore", param: "")
    }
    
    func logPostReport(postId: Int) {
        postPostAction(postId: postId, action: "report", param: "")
    }
    
    
    func postPostAction(postId: Int, action: String, param: String) {
        provider.rx.request(SnipLoggerService.logPostAction(postId: postId, action: action, param: param))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .subscribe(onSuccess: { (response) in
                //print("Sent log (postId: \(String(postId)), action: \(action), param: \(param))")
            }) { (err) in
                print("Error sending log (postId: \(String(postId)), action: \(action), param: \(param)) error: \(err)")
                Crashlytics.sharedInstance().recordError(err)
            }
            .disposed(by: disposeBag)
    }
    
    func postActionParam(action: String, param: String) {
        provider.rx.request(SnipLoggerService.logActionParam(action: action, param: param))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .subscribe(onSuccess: { (response) in
                //print("Sent log (action: \(action), param: \(param))")
            }) { (err) in
                print("Error sending log (action: \(action), param: \(param)) error: \(err)")
                Crashlytics.sharedInstance().recordError(err)
            }
            .disposed(by: disposeBag)
    }
    
}
