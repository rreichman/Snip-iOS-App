//
//  PostListCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/21/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import RxSwift
import Crashlytics
enum FeedMode {
    case category(category: Category)
    case writer(writer: User)
    case savedSnips
    case likedSnips
}
protocol GeneralFeedCoordinatorDelegate: class {
    func onLeaveFeed()
}

fileprivate enum LoadingState {
    case loadingPage
    case notLoading
}

class GeneralFeedCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var disposeBag: DisposeBag = DisposeBag()
    
    var navController: UINavigationController!
    var postListVC: FeedCollectionViewController!
    var category: Category!
    
    var delegate: GeneralFeedCoordinatorDelegate?

    //fileprivate var _loadingState: LoadingState = .loadingPage
    var postCotainer: PostContainer!
    var writer: User!
    let mode: FeedMode
    
    
    init(nav: UINavigationController, mode: FeedMode) {
        self.navController = nav
        
        switch mode {
        case .category(let category):
            self.category = category
        case .writer(let writer):
            self.writer = writer
            let realm = RealmManager.instance.getMemRealm()
            let postCotainer = PostContainer()
            postCotainer.key = writer.username
            try! realm.write {
                realm.add(postCotainer, update: true)
            }
            self.postCotainer = postCotainer
            
            SnipLoggerRequests.instance.logAuthorProfileView(authorUserName: writer.username)
        case .savedSnips:
            let realm = RealmManager.instance.getMemRealm()
            let postCotainer = PostContainer()
            postCotainer.key = SessionManager.instance.currentLoginUsername! + "-saved-snips"
            try! realm.write {
                realm.add(postCotainer, update: true)
            }
            self.postCotainer = postCotainer
            
            SnipLoggerRequests.instance.logSavedPostsViewed()
        case .likedSnips:
            let realm = RealmManager.instance.getMemRealm()
            let postCotainer = PostContainer()
            postCotainer.key = SessionManager.instance.currentLoginUsername! + "-liked-snips"
            try! realm.write {
                realm.add(postCotainer, update: true)
            }
            self.postCotainer = postCotainer
            SnipLoggerRequests.instance.logFavoritePostsViewed()
        }
        self.mode = mode
        
    }
    
    func start(animated: Bool = true) {
        loadFirstPage()
        self.postListVC = FeedCollectionViewController()
        self.postListVC.delegate = self
        
        switch self.mode {
        case .category:
            self.postListVC.bindData(feedType: .list(posts: category.posts, navTitle: category.categoryName, writer: nil))
        case .writer:
            self.postListVC.bindData(feedType: .list(posts: getPostListForMode(), navTitle: "", writer: writer))
        case .savedSnips:
            self.postListVC.bindData(feedType: .list(posts: getPostListForMode(), navTitle: "SAVED SNIPS", writer: nil))
        case .likedSnips:
            self.postListVC.bindData(feedType: .list(posts: getPostListForMode(), navTitle: "FAVORITE SNIPS", writer: nil))
        }
        navController.pushViewController(self.postListVC, animated: animated)
    }
    
    func getPostListForMode() -> List<Post> {
        switch self.mode {
        case .category:
            return self.category.posts
        case .writer:
            return self.postCotainer.posts
        case .savedSnips:
            return self.postCotainer.posts
        case .likedSnips:
            return self.postCotainer.posts
        }
    }
    func getParamsForMode() -> [String: String] {
        switch self.mode {
        case .category:
            return category.paramDictionary as! [String: String]
        case .writer:
            return ["writer": self.writer.username]
        case .savedSnips:
            return [:]
        case .likedSnips:
            return [:]
        }
    }
    
    func getRequestForMode() -> Single< (Int, [ Post ]) > {
        switch self.mode {
        //Not used for category, do not use this function for category requests
        case .category:
            return SnipRequests.instance.getSavedSnips(nextPage: self.postCotainer.nextPage)
        case .writer:
            return SnipRequests.instance.getPostPageForQuery(params: getParamsForMode(), nextPage: self.postCotainer.nextPage)
        case .savedSnips:
            return SnipRequests.instance.getSavedSnips(nextPage: self.postCotainer.nextPage)
        case .likedSnips:
            return SnipRequests.instance.getLikedSnips(nextPage: self.postCotainer.nextPage)
        }
    }
    
    func loadNextPage() {
        //print("load next page")
        let realm = RealmManager.instance.getMemRealm()
        switch self.mode {
        case .category:
            if self.category.nextPage == -1 {
                self.postListVC.endOfFeed()
            }
            SnipRequests.instance.getNextPage(for: category)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: {[weak self] (categorty) in
                    guard let s = self else {return}
                    try! realm.write {
                        realm.add(s.category, update: true)
                    }
                }) { [weak self](err) in
                    print(err)
                    Crashlytics.sharedInstance().recordError(err)
                    
                    guard let s = self else { return }
                    guard let _ = s.postListVC else { return }
                    s.postListVC.endRefreshing()
                }.disposed(by: disposeBag)
        default:
            if self.postCotainer.nextPage == -1 {
                self.postListVC.endOfFeed()
            }
            getRequestForMode()
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: {[weak self] (nextPage, result) in
                    guard let s = self else {return}
                    let add_set = result.filter({ (post) -> Bool in
                        return s.postCotainer.posts.index(of: post) == nil
                    })
                    try! realm.write {
                        s.postCotainer.nextPage = nextPage
                        realm.add(result, update: true)
                        s.postCotainer.posts.append(objectsIn: add_set)
                    }
                    
                }) { [weak self](err) in
                    print(err)
                    Crashlytics.sharedInstance().recordError(err)
                    
                    guard let s = self else { return }
                    guard let _ = s.postListVC else { return }
                    s.postListVC.endRefreshing()
            }.disposed(by: disposeBag)
        }
        
    }
    func loadFirstPage() {
        //print("loadFirstPage")
        let realm = RealmManager.instance.getMemRealm()
        
        switch self.mode {
        case .category:
            try! realm.write {
                category.nextPage = nil
                category.posts.removeAll()
            }
            SnipRequests.instance.getNextPage(for: self.category)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] (cat) in
                    print("post list updated")
                    guard let s = self else { return }
                    guard let vc = s.postListVC else { return }
                    
                    vc.endRefreshing()
                }) { [weak self] (err) in
                    print(err)
                    Crashlytics.sharedInstance().recordError(err)
                    guard let s = self else { return }
                    guard let vc = s.postListVC else { return }
                    vc.endRefreshing()
                }.disposed(by: self.disposeBag)
        default:
            try! realm.write {
                self.postCotainer.posts.removeAll()
                self.postCotainer.nextPage = nil
            }
            getRequestForMode()
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: {[weak self] (nextPage, results) in
                    guard let s = self, let vc = s.postListVC else {return}
                    let add_set = results.filter({ (post) -> Bool in
                        return s.postCotainer.posts.index(of: post) == nil
                    })
                    try! realm.write {
                        s.postCotainer.nextPage = nextPage
                        realm.add(results, update: true)
                        s.postCotainer.posts.append(objectsIn: add_set)
                    }
                    vc.endRefreshing()
                }) { [weak self](err) in
                    print(err)
                    Crashlytics.sharedInstance().recordError(err)
                    
                    guard let s = self, let vc = s.postListVC else {return}
                    vc.endRefreshing()
                }.disposed(by: disposeBag)
            
        }
    }
    func pushDetailViewController(for post: Post, _ startComment: Bool) {
        let c = PostDetailCoordinator(navigationController: self.navController, post: post, mode: (startComment ? .startComment : .showComments))
        childCoordinators.append(c)
        c.start()
    }
    
    func popViewController() {
        self.navController.popViewController(animated: true)
        if let d = self.delegate {
            d.onLeaveFeed()
        }
    }
}

extension GeneralFeedCoordinator: FeedViewDelegate {
    
    func openInternalLink(url: URL) {
        AppLinkUtils.resolveAndPushAppLink(link: url.absoluteString, navigationController: self.navController)
    }
    
    func showWriterPosts(writerUsername: String) {
        let realm = RealmManager.instance.getMemRealm()
        guard let writer = realm.object(ofType: User.self, forPrimaryKey: writerUsername) else { return }
        switch self.mode {
        case .writer:
            if self.writer.username == writer.username {
                print("User requsted a writers posts, but we are already showing that writers posts")
                return
            }
        default:
            break
        }
        let coord = GeneralFeedCoordinator(nav: self.navController, mode: .writer(writer: writer))
        self.childCoordinators.append(coord)
        coord.start()
        
    }
    
    func showDetail(postId: Int, startComment: Bool) {
        let realm = RealmManager.instance.getMemRealm()
        guard let post = realm.object(ofType: Post.self, forPrimaryKey: postId) else { return }
        pushDetailViewController(for: post, startComment)
        
    }
    
    func refreshFeed() {
        loadFirstPage()
        
    }
    
    func fetchNextPage() {
        loadNextPage()
    }
    
    func showCategoryPosts(categoryName: String) {
        // Pass
    }
    
    func viewDidAppearForTheFirstTime() {
        // Pass
    }
    
    func showExpandedImageView(for post: Post) {
        // Pass
    }
}
