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
    var category: Category
    fileprivate var loadingState: LoadingState = .loadingPage
    init(nav: UINavigationController, category: Category) {
        self.navController = nav
        self.category = category
    }
    
    func start() {
        loadFirstPage()
        self.postListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedNavigationViewController") as! PostListViewController
        self.postListVC.delegate = self
        self.postListVC.setPostQuery(posts: category.posts, description: category.categoryName)
        navController.pushViewController(self.postListVC, animated: true)
    }
    func loadNextPage() {
        //print("load next page")
        let realm = RealmManager.instance.getMemRealm()
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
    }
    func loadFirstPage() {
        //print("loadFirstPage")
        let realm = RealmManager.instance.getMemRealm()
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
    }
    
    func popViewController() {
        self.navController.popViewController(animated: true)
    }
}

extension GeneralFeedCoordinator: FeedNavigationViewDelegate {
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
