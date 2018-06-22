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
    var postListVC: PostListViewController!
    var category: Category!
    
    var delegate: GeneralFeedCoordinatorDelegate?
    
    fileprivate var loadingState: LoadingState {
        get {
            print("someone got loadingState, it is \(_loadingState)")
            return _loadingState
        }
        set {
            print("someone set loadingState to \(newValue)")
            _loadingState = newValue
        }
    }
    fileprivate var _loadingState: LoadingState = .loadingPage
    var postCotainer: PostContainer!
    var writer: User!
    let mode: FeedMode
    
    var tempHack: Bool = false
    
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
        case .savedSnips:
            let realm = RealmManager.instance.getMemRealm()
            let postCotainer = PostContainer()
            postCotainer.key = SessionManager.instance.currentLoginUsername! + "-saved-snips"
            try! realm.write {
                realm.add(postCotainer, update: true)
            }
            self.postCotainer = postCotainer
        case .likedSnips:
            let realm = RealmManager.instance.getMemRealm()
            let postCotainer = PostContainer()
            postCotainer.key = SessionManager.instance.currentLoginUsername! + "-liked-snips"
            try! realm.write {
                realm.add(postCotainer, update: true)
            }
            self.postCotainer = postCotainer
        }
        self.mode = mode
        
    }
    
    func start() {
        loadFirstPage()
        self.postListVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "FeedNavigationViewController") as! PostListViewController
        self.postListVC.delegate = self
        
        switch self.mode {
        case .category:
            self.postListVC.bindData(posts: category.posts, description: category.categoryName)
        case .writer:
            self.postListVC.bindData(posts: getPostListForMode(), description: "")
            self.postListVC.setUserHeader(name: "\(writer.first_name) \(writer.last_name)", initials: writer.initials)
        case .savedSnips:
            self.postListVC.bindData(posts: getPostListForMode(), description: "SAVED SNIPS")
        case .likedSnips:
            self.postListVC.bindData(posts: getPostListForMode(), description: "FAVORITE SNIPS")
        }
        navController.pushViewController(self.postListVC, animated: true)
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
                self.loadingState = .notLoading
                return
            }
            SnipRequests.instance.getNextPage(for: category)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: {[weak self] (categorty) in
                    guard let s = self else {return}
                    try! realm.write {
                        realm.add(s.category, update: true)
                    }
                    s.loadingState = .notLoading
                }) { [weak self](err) in
                    print(err)
                    Crashlytics.sharedInstance().recordError(err)
                    
                    guard let s = self else { return }
                    guard let _ = s.postListVC else { return }
                    s.postListVC.endRefreshing()
                    s.loadingState = .notLoading
                }.disposed(by: disposeBag)
        default:
            if self.postCotainer.nextPage == -1 {
                self.loadingState = .notLoading
                return
                
            }
            getRequestForMode()
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: {[weak self] (nextPage, result) in
                    guard let s = self else {return}

                    try! realm.write {
                        s.postCotainer.nextPage = nextPage
                        for newPost in result {
                            if s.postCotainer.posts.index(of: newPost) == nil {
                                realm.add(newPost, update: true)
                                s.postCotainer.posts.append(newPost)
                            }
                        }
                    }
                    
                    s.loadingState = .notLoading
                }) { [weak self](err) in
                    print(err)
                    Crashlytics.sharedInstance().recordError(err)
                    
                    guard let s = self else { return }
                    guard let _ = s.postListVC else { return }
                    s.loadingState = .notLoading
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
                    s.loadingState = .notLoading
                }) { [weak self] (err) in
                    print(err)
                    Crashlytics.sharedInstance().recordError(err)
                    guard let s = self else { return }
                    guard let vc = s.postListVC else { return }
                    vc.endRefreshing()
                    s.loadingState = .notLoading
                }.disposed(by: self.disposeBag)
        default:
            try! realm.write {
                self.postCotainer.posts.removeAll()
                self.postCotainer.nextPage = nil
            }
            getRequestForMode()
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: {[weak self] (nextPage, results) in
                    guard let s = self else {return}
                    try! realm.write {
                        s.postCotainer.nextPage = nextPage
                        for newPost in results {
                            if s.postCotainer.posts.index(of: newPost) == nil {
                                realm.add(newPost, update: true)
                                s.postCotainer.posts.append(newPost)
                            }
                        }
                    }
                    s.loadingState = .notLoading
                }) { [weak self](err) in
                    print(err)
                    Crashlytics.sharedInstance().recordError(err)
                    
                    guard let s = self else { return }
                    s.postListVC.endRefreshing()
                    s.loadingState = .notLoading
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

extension GeneralFeedCoordinator: FeedNavigationViewDelegate {
    func openInternalLink(url: URL) {
        AppLinkUtils.resolveAndPushAppLink(link: url.absoluteString, navigationController: self.navController)
    }
    
    func viewWriterPosts(for writer: User) {
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
    
    func showDetail(for post: Post, startComment: Bool) {
        pushDetailViewController(for: post, startComment)
    }
    
    func refreshFeed() {
        if loadingState == .notLoading {
            loadingState = .loadingPage
            loadFirstPage()
        } else {
            postListVC.endRefreshing()
        }
        
    }
    
    func fetchNextPage() {
        if loadingState == .notLoading {
            loadingState = .loadingPage
            loadNextPage()
        }
    }
    
    func onBackPressed() {
        if tempHack {
            navController.navigationBar.isHidden = true
        }
        popViewController()
        
    }
}
