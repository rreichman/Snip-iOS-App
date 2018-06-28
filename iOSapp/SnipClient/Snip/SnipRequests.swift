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
import RealmSwift

class SnipRequests {
    
    static let instance = SnipRequests()
    
    let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
            do {
                var request: URLRequest = try endpoint.urlRequest()
                request.httpShouldHandleCookies = false
                done(.success(request))
            } catch {
                done(.failure(MoyaError.underlying(error, nil)))
            }
    }
    
    let provider: MoyaProvider<SnipService>.CompatibleType
    let disposeBag: DisposeBag = DisposeBag()
    init() {
        self.provider = MoyaProvider<SnipService>(requestClosure: requestClosure)
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
                        sr.populatePostFields(for: post)
                    }
                }
                return categories
        }
    }
    
    func getNextPage(for category: Category) -> Single<Category> {
        if category.nextPage == -1 {
            return Single.just(category)
        }
        return provider.rx.request(SnipService.postQuery(params: category.paramDictionary, page: category.nextPage))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .map { [weak self] obj in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                var next_page: Int!
                if let next_page_maybe = json["next_page"] as? Int  {
                    next_page = next_page_maybe
                } else {
                    next_page = -1
                }
                guard let s = self else { throw SerializationError.missing("self") }
                let page = try Post.parsePostPage(json: json)
                let realm = RealmManager.instance.getMemRealm()
                for post in page {
                    try! realm.write {
                        realm.add(post, update: true)
                        if category.posts.index(of: post) == nil {
                            category.posts.append(post)
                        }
                    }
                    s.populatePostFields(for: post)
                }
                category.nextPage = next_page
                return category
            }
    }
    
    func getPostPageForQuery(params: [String: String], nextPage: Int?) -> Single< (Int, [ Post ]) > {
        if nextPage == -1 {
            return Single.just( (-1, []) )
        }
        
        return provider.rx.request(SnipService.postQuery(params: params, page: nextPage))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .map { [weak self] obj in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                var next_page: Int!
                if let next_page_maybe = json["next_page"] as? Int  {
                    next_page = next_page_maybe
                } else {
                    next_page = -1
                }
                guard let s = self else { throw SerializationError.missing("self") }
                let page = try Post.parsePostPage(json: json)
                var result: [ Post ] = []
                for post in page {
                    s.populatePostFields(for: post)
                    result.append(post)
                }
                return (next_page, result)
        }
    }
    
    func getSavedSnips(nextPage: Int?) -> Single<(Int, [ Post ])> {
        if nextPage == -1 {
            return Single.just( (-1, []) )
        }
        return provider.rx.request(SnipService.getSavedSnips(page: nextPage))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .map { [weak self] obj in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                var next_page: Int!
                if let next_page_maybe = json["next_page"] as? Int  {
                    next_page = next_page_maybe
                } else {
                    next_page = -1
                }
                guard let s = self else { throw SerializationError.missing("self") }
                let page = try Post.parsePostPage(json: json)
                var results: [ Post ] = []
                for post in page {
                    s.populatePostFields(for: post)
                    results.append(post)
                }
                return (next_page, results)
        }
    }
    func getLikedSnips(nextPage: Int?) -> Single<(Int, [ Post ])> {
        if nextPage == -1 {
            return Single.just( (-1, []) )
        }
        return provider.rx.request(SnipService.getLikedSnips(page: nextPage))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .map { [weak self] obj in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                var next_page: Int!
                if let next_page_maybe = json["next_page"] as? Int  {
                    next_page = next_page_maybe
                } else {
                    next_page = -1
                }
                guard let s = self else { throw SerializationError.missing("self") }
                let page = try Post.parsePostPage(json: json)
                var results: [ Post ] = []
                for post in page {
                    s.populatePostFields(for: post)
                    results.append(post)
                }
                return (next_page, results)
        }
    }
    
    func getPostFromAppLink(url: String) -> Single<Post> {
        return provider.rx.request(SnipService.getAppLink(url: url))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .map { [weak self] obj in
                guard let s = self else { throw SerializationError.missing("self")}
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj) }
                if let _ = json["posts"] as? [ [String: Any] ]{
                    let post_list = try Post.parsePostPage(json: json)
                    if post_list.count > 0 {
                        SnipRequests.instance.populatePostFields(for: post_list[0])
                        return post_list[0]
                    } else {
                        throw APIError.unableToResolveAppLink(of: url)
                    }
                } else if let post_json = json["main_post"] as? [String: Any] {
                    let post = try Post.parseJson(json: post_json)
                    SnipRequests.instance.populatePostFields(for: post)
                    return post
                } else {
                    throw APIError.unableToResolveAppLink(of: url)
                }
        }
    }
    
    func populatePostFields(for post: Post) {
        getPostImage(for: post)
        /**
        for comment in post.comments {
            if let commentAuthor = comment.writer {
                SnipRequests.instance.getUserAvatar(for: commentAuthor)
            }
        }
        if let author = post.author {
            getUserAvatar(for: author)
        }
        **/
    }
    
    // Post objects should already have an Image Object added to the realm, so no need to make one and add it here like in getUserAvatar()
    func getPostImage(for post: Post) {
        guard let image = post.image else { return }
        if image.hasData {
            return
        }
        let realm = image.realm == nil ? RealmManager.instance.getMemRealm() : image.realm!
        provider.rx.request(SnipService.getPostImage(imageURL: image.imageUrl))
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))
            .mapSnipRequest()
            .map { response -> Data in
                return response.data
            }
            .observeOn(MainScheduler.instance)
            .retry(3)
            .subscribe(onSuccess: { (imageData) in
                try! realm.write {
                    image.data = imageData
                    image.failed_loading = false
                }
            }, onError: { (err) in
                Crashlytics.sharedInstance().recordError(err, withAdditionalUserInfo: ["imageURL": image.imageUrl ])
                print("Error loading image for post \(post.id), \(image.imageUrl) \(err)")
                
                try! realm.write {
                    image.data = nil
                    image.failed_loading = true
                }
            })
            .disposed(by: disposeBag)
    }
    /**
    func getUserAvatar(for user: User) {
        if user.avatarUrl == "" || user.hasAvatarImageData() {
            return
        }
        
        let realm = user.realm == nil ? RealmManager.instance.getMemRealm() : user.realm!
        
        if let cached_image = realm.object(ofType: Image.self, forPrimaryKey: user.avatarUrl) {
            print("Avatar Image cache hit")
            try! realm.write {
                user.avatarImage = cached_image
            }
            if cached_image.hasData {
                print("Cached image object has data, returning")
                return
            }
            print("Cached image object does not have data, loading ...")
        } else {
            print("Avatar Image cache miss")
            let image = Image.buildSimpleImage(with: user.avatarUrl)
            try! realm.write {
                realm.add(image, update: true)
                user.avatarImage = image
            }
        }
        
        provider.rx.request(SnipService.getPostImage(imageURL: user.avatarUrl))
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))
            .mapSnipRequest()
            .map { response -> Data in
                return response.data
            }
            .retry(3)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [ realm ] (imageData) in
                try! realm.write {
                    user.avatarImage!.data = imageData
                    user.avatarImage!.failed_loading = false
                }
            }, onError: { (err) in
                print("Error loading avatar for user \(user.username), \(err)")
                Crashlytics.sharedInstance().recordError(err)
                try! realm.write {
                    user.avatarImage!.data = nil
                    user.avatarImage!.failed_loading = true
                }
            })
            .disposed(by: self.disposeBag)
    }
     **/
    
    func fetchAndSaveLoggedInUser() {
        return provider.rx.request(SnipService.getUserProfile)
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .map { obj -> User in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj)}
                let user = try User.parseJson(json: json)
                return user
            }
            .subscribe(onSuccess: { (user) in
                print("Fetched profile for user \(user.username)")
                let realm = RealmManager.instance.getRealm()
                try! realm.write {
                    realm.add(user, update: true)
                }
            }, onError: { (err) in
                print("Error fetch profile for logged in user")
                Crashlytics.sharedInstance().recordError(err)
            })
            .disposed(by: disposeBag)
        
    }
    
    func postVoteState(post_id: Int, vote_val: Double) {
        let _ = provider.rx.request(SnipService.postVote(post_id: post_id, vote_value: vote_val))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .subscribe(onSuccess: { (resp) in
                print("\(post_id) vote val set to \(vote_val)")
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
                Crashlytics.sharedInstance().recordError(err)
            }
    }
    func postSaveState(post_id: Int) {
        let _ = provider.rx.request(SnipService.postSave(post_id: post_id))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .subscribe(onSuccess: { (resp) in
                print("\(post_id) saved/unsaved")
            }) { (err) in
                print("error voting\(err)")
                Crashlytics.sharedInstance().recordError(err)
            }
    }
    
    func postCommentToPost(for post: Post, body: String, parent: RealmComment?) {
        let realm = RealmManager.instance.getMemRealm()
        var cached: RealmComment?
        if let un = SessionManager.instance.currentLoginUsername,
            let writerDisk = RealmManager.instance.getRealm().object(ofType: User.self, forPrimaryKey: un) {
            var writer: User = User()
            writer.username = writerDisk.username
            writer.avatarUrl = writerDisk.avatarUrl
            writer.first_name = writerDisk.first_name
            writer.last_name = writerDisk.last_name
            writer.wallet_address = writerDisk.wallet_address
            try! realm.write {
                realm.add(writer, update: true)
                writer = realm.object(ofType: User.self, forPrimaryKey: writer.username)!
            }
            let c = RealmComment()
            c.body = body
            c.writer = writer
            c.date = Date()
            if let p = parent {
                c.parent = p
                c.parent_id.value = p.id
                c.level = p.level + 1
                
            }
            c.id = c.body.hashValue
            try! realm.write {
                realm.add(c, update: true)
                post.comments.append(c)
            }
            cached = c
        }
        
        let _ = provider.rx.request(SnipService.postComment(post_id: post.id, parent_id: parent?.id, body: body))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .map { obj -> RealmComment in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("json", obj)}
                let published_comment = try RealmComment.parseJson(json: json)
                return published_comment
            }
            .observeOn(MainScheduler.instance)
            
            .subscribe(onSuccess: { published_comment in
                try! realm.write{
                    if let c = cached, let index = post.comments.index(of: c) {
                        post.comments.remove(at: index)
                    }
                    if post.comments.index(of: published_comment) == nil {
                        realm.add(published_comment, update: true)
                        post.comments.append(published_comment)
                    }
                }
            }) { err in
                print("Error posting comment with body text \(body), err: \(err)")
                Crashlytics.sharedInstance().recordError(err)
                try! realm.write{
                    if let c = cached, let index = post.comments.index(of: c) {
                        post.comments.remove(at: index)
                    }
                }
                print(err)
            }
    }
    
    func postCommentEdit(post_id: Int, comment: RealmComment, newBody: String) {
        let realm = RealmManager.instance.getMemRealm()
        try! realm.write {
            comment.body = newBody
        }
        
        let _ = provider.rx.request(SnipService.editComment(post_id: post_id, comment_id: comment.id, body: newBody))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .map { obj -> Bool in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("Json", obj)}
                print("Successfully edited \(comment.id)")
                return true
            }
            .subscribe(onSuccess: { (success) in
                print("postCommentEdit() success")
            }) { (err) in
                print("postCommentEdit() error \(err)")
                Crashlytics.sharedInstance().recordError(err)
        }
    }
    
    func postDeleteComment(comment: RealmComment) {
        let comment_id = comment.id
        let realm = RealmManager.instance.getMemRealm()
        try! realm.write {
            if comment.childComments.count != 0 {
                comment.body = "[This comment has been deleted]"
            } else {
                realm.delete(comment)
            }
        }
        let _ = provider.rx.request(SnipService.deleteComment(comment_id: comment_id))
            .subscribeOn(MainScheduler.instance)
            .mapSnipRequest()
            .mapJSON()
            .map { obj -> Bool in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("JSON", obj) }
                guard let msg = json["message"] as? String else { throw SerializationError.missing("message") }
                if msg != "success" {
                    return false
                }
                guard let post_ids = json["deleted"] as? [ Int ] else { throw SerializationError.missing("deleted") }
                if post_ids.count > 0 {
                    if post_ids[0] == comment_id {
                        return true
                    }
                }
                return false
            }
            .subscribe(onSuccess: { (success) in
                if success {
                    print("Successfully deleted comment \(comment_id)")
                    
                } else {
                    print("Error deleting comment \(comment_id)")
                }
            }) { (err) in
                print("Error deleting comment \(comment_id): \(err)")
                Crashlytics.sharedInstance().recordError(err)
            }
    }
    
    func postReport(post_id: Int, reason: String, param1: String) {
        provider.rx.request(SnipService.postReport(post_id: post_id, reason: reason, param1: param1))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .subscribe(onSuccess: { (response) in
                print("Report submitted for post \(String(post_id)) for reason \(reason) (param1 \(param1)")
            }) { (err) in
                print("Error submitting report for post \(post_id), err: \(err)")
                Crashlytics.sharedInstance().recordError(err)
            }
            .disposed(by: disposeBag)
    }
}
