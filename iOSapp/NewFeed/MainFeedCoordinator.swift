//
//  FeedNavigationCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import RxSwift

fileprivate enum LoadingState {
    case loadingPage
    case notLoading
}

class MainFeedCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController!
    var mainFeedController: MainFeedViewController!
    var disposeBag: DisposeBag = DisposeBag()
    fileprivate var loadingState: LoadingState = .loadingPage
    init() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        navigationController = storyBoard.instantiateViewController(withIdentifier: "FeedNavigationController") as! UINavigationController
        mainFeedController = storyBoard.instantiateViewController(withIdentifier: "HomeFeedViewController") as! MainFeedViewController
        navigationController.viewControllers = [ mainFeedController ]
    }
    
    func start() {
        let realm = RealmManager.instance.getMemRealm()
        let categories = realm.objects(Category.self)
        mainFeedController.setCategoryList(categories: categories)
        mainFeedController.delegate = self
        loadingState = .notLoading
    }
    
    func loadMainFeed() {
        let realm = RealmManager.instance.getMemRealm()
        SnipRequests.instance.getMain()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self](catList) in
                try! realm.write {
                    for category in catList {
                        realm.add(category, update: true)
                    }
                }
                catList.forEach({ (cat) in
                    cat.topThreePosts.forEach({ (post) in
                        let headline = post.headline
                        let short = String(headline[..<headline.index(headline.startIndex, offsetBy: 20)])
                        print("\(post.id):\(short) isSaved \(post.saved)")
                    })
                })
                guard let s = self else { return }
                s.loadingState = .notLoading
                guard let vc = s.mainFeedController else { return }
                vc.endRefreshing()
                
            }) { [weak self] (err) in
                print(err)
                Crashlytics.sharedInstance().recordError(err)
                //Continue anyway, this is just a preload
                guard let coordinator = self else { return }
                guard let vc = coordinator.mainFeedController else { return }
                vc.endRefreshing()
            }
            .disposed(by: disposeBag)
    }
    
    func pushDetailViewController(for post: Post) {
        let c = PostDetailCoordinator(navigationController: self.navigationController, post: post)
        childCoordinators.append(c)
        c.start()
    }
    func openPostList(for category: Category) {
        let post_coordinator = GeneralFeedCoordinator(nav: self.navigationController, mode: .category(category: category))
        self.childCoordinators.append(post_coordinator)
        post_coordinator.start()
    }
}

extension MainFeedCoordinator: MainFeedViewDelegate {
    func showWriterPosts(writer: User) {
        let coord = GeneralFeedCoordinator(nav: self.navigationController, mode: .writer(writer: writer))
        self.childCoordinators.append(coord)
        coord.start()
    }
    func showDetail(for post: Post) {
        pushDetailViewController(for: post)
    }
    
    func onCategorySelected(category: Category) {
        print("\(category.categoryName) selected")
        openPostList(for: category)
    }
    func refreshFeed() {
        if loadingState != .loadingPage {
            loadMainFeed()
        }
    }
}
