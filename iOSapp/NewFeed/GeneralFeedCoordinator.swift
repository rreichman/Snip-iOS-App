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
}
protocol PostListCoordinatorDelegate: class {
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
    fileprivate var loadingState: LoadingState = .loadingPage
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
            try! realm.write {
                realm.add(postCotainer)
            }
            self.postCotainer = postCotainer
        case .savedSnips:
            let realm = RealmManager.instance.getMemRealm()
            let postCotainer = PostContainer()
            try! realm.write {
                realm.add(postCotainer)
            }
            self.postCotainer = postCotainer
        }
        self.mode = mode
        
    }
    
    func getPostListForMode() -> List<Post> {
        switch self.mode {
        case .category:
            return self.category.posts
        case .writer:
            return self.postCotainer.posts
        case .savedSnips:
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
        }
    }
    
    func start() {
        loadFirstPage()
        self.postListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedNavigationViewController") as! PostListViewController
        self.postListVC.delegate = self
        
        switch self.mode {
        case .category:
            self.postListVC.setPostQuery(posts: category.posts, description: category.categoryName)
        case .writer:
            self.postListVC.setPostQuery(posts: getPostListForMode(), description: "")
            self.postListVC.setUserHeader(name: "\(writer.first_name) \(writer.last_name)", initials: writer.initials)
        case .savedSnips:
            self.postListVC.setPostQuery(posts: getPostListForMode(), description: "")
        }
        
        navController.pushViewController(self.postListVC, animated: true)
    }
    func loadNextPage() {
        //print("load next page")
        let realm = RealmManager.instance.getMemRealm()
        
        switch self.mode {
        case .category:
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
                    s.loadingState = .notLoading
                }.disposed(by: disposeBag)
        case .writer:
            SnipRequests.instance.getPostPageForQuery(list: getPostListForMode(), params: getParamsForMode(), nextPage: self.postCotainer.nextPage)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: {[weak self] (nextPage) in
                    guard let s = self else {return}
                    try! realm.write {
                        s.postCotainer.nextPage = nextPage
                    }
                    s.loadingState = .notLoading
                }) { [weak self](err) in
                    print(err)
                    Crashlytics.sharedInstance().recordError(err)
                    
                    guard let s = self else { return }
                    guard let _ = s.postListVC else { return }
                    s.loadingState = .notLoading
            }.disposed(by: disposeBag)
        case .savedSnips:
            break
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
        case .writer:
            try! realm.write {
                self.postCotainer.posts.removeAll()
                self.postCotainer.nextPage = nil
            }
            SnipRequests.instance.getPostPageForQuery(list: getPostListForMode(), params: getParamsForMode(), nextPage: self.postCotainer.nextPage)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: {[weak self] (nextPage) in
                    guard let s = self else {return}
                    try! realm.write {
                        s.postCotainer.nextPage = nextPage
                    }
                    s.loadingState = .notLoading
                }) { [weak self](err) in
                    print(err)
                    Crashlytics.sharedInstance().recordError(err)
                    
                    guard let s = self else { return }
                    s.loadingState = .notLoading
                }.disposed(by: disposeBag)
        case .savedSnips:
            break
            
        }
    }
    func pushDetailViewController(for post: Post) {
        let c = PostDetailCoordinator(navigationController: self.navController, post: post)
        childCoordinators.append(c)
        c.start()
    }
    
    func popViewController() {
        self.navController.popViewController(animated: true)
    }
}

extension GeneralFeedCoordinator: FeedNavigationViewDelegate {
    func viewWriterPosts(for writer: User) {
        let coord = GeneralFeedCoordinator(nav: self.navController, mode: .writer(writer: writer))
        self.childCoordinators.append(coord)
        coord.start()
    }
    
    func showDetail(for post: Post) {
        pushDetailViewController(for: post)
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
        popViewController()
    }
}
