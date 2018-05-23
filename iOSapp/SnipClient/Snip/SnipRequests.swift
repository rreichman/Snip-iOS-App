//
//  SnipRequests.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Crashlytics

class SnipRequests {
    
    static let instance = SnipRequests()
    
    let provider: MoyaProvider<SnipService>.CompatibleType
    let disposeBag: DisposeBag = DisposeBag()
    init() {
        self.provider = MoyaProvider<SnipService>()
    }
    
    func getMain() -> Single<[Category]> {
        return provider.rx.request(SnipService.main)
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .map { [weak self] obj -> [Category] in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("invalid json response", obj) }
                guard let jsonList = json["posts_data"] as? [ [String: Any] ] else { throw SerializationError.missing("posts_data") }
                let categories = try Category.parseJsonList(json: jsonList)
                guard let sr = self else {
                    return categories
                }
                for cat in categories {
                    for post in cat.topThreePosts {
                        let _ = sr.getPostImage(for: post)
                            .subscribe()
                    }
                }
                return categories
        }
    }
    
    func getNextPage(for category: Category) -> Single<Category> {
        return provider.rx.request(SnipService.postQuery(params: category.paramDictionary, page: category.nextPage))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .map { [weak self] obj in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                guard let next_page = json["next_page"] as? Int else { throw SerializationError.missing("next_page") }
                guard let s = self else { throw SerializationError.missing("self") }
                let page = try Post.parsePostPage(json: json)
                let realm = RealmManager.instance.getMemRealm()
                for post in page {
                    let _ = s.getPostImage(for: post)
                        .subscribe()
                    try! realm.write {
                        realm.add(post, update: true)
                        if category.posts.index(of: post) == nil {
                            
                            category.posts.append(post)
                            print("Post appended to a category under a write")
                        }
                    }
                }
                category.nextPage = next_page
                return category
            }
    }
    
    func getPostImage(for post: Post) -> Single<Bool> {
        guard let image = post.image else { return Single.just(false) }
        if image.hasData {
            return Single.just(true)
        }
        return provider.rx.request(SnipService.getPostImage(imageURL: image.imageUrl))
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))
            .mapSnipRequest()
            .map { response -> Data in
                return response.data
            }
            .observeOn(MainScheduler.instance)
            .map { data -> Bool in
                print("got image data for img \(image.imageUrl)")
                let realm = RealmManager.instance.getMemRealm()
                try! realm.write {
                    image.data = data
                }
                return true
            }
            .catchError({ (err) -> Single<Bool> in
                Crashlytics.sharedInstance().recordError(err, withAdditionalUserInfo: ["imageURL": image.imageUrl ])
                print("Error loading \(image.imageUrl) \(err)")
                return Single.just(false)
            })
    }
    
    func getUser() -> Single<User> {
        return provider.rx.request(SnipService.getUserProfile)
            .subscribeOn(SingleBackgroundThread.scheduler)
            .mapSnipRequest()
            .mapJSON()
            .map { obj in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj)}
                
                let user = try User.parseJson(json: json)
                return user
        }
    }
    
    func buildProfile(authToken: String?) {
        guard let token = authToken else { return }
        let _ = provider.rx.request(SnipService.buildUserProfile(authToken: token))
            .subscribeOn(SingleBackgroundThread.scheduler)
            .mapSnipRequest()
            .mapJSON()
            .map { obj -> User in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj)}
                let user = try User.parseJson(json: json)
                return user
            }
            .observeOn(MainScheduler.instance)
            .map { user in
                let realm = RealmManager.instance.getMemRealm()
                try! realm.write {
                    realm.add(user, update: true)
                }
                SessionManager.instance.authToken = token
                SessionManager.instance.currentLoginUsername = user.username
                print("Logged in as \(user.username) using token \(token)")
            }
            .subscribe()
    }
    
    func postVoteState(post_id: Int, vote_val: Double) {
        let _ = provider.rx.request(SnipService.postVote(post_id: post_id, vote_value: vote_val))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .subscribe(onSuccess: { (resp) in
                print("vote successful")
            }) { (err) in
                print("error voting\(err)")
                if let requestError = err as? APIError {
                    print(requestError)
                    switch requestError {
                    case .requestError(let errorMessage, let code, let response):
                        print(response)
                    default:
                        break
                    }
                }
            }
    }
}
