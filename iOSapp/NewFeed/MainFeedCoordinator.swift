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
    
    var openInitialAppLink: Bool = false
    var appLink: URL?
    init(openInitialAppLink: Bool, appLink: URL?) {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        navigationController = storyBoard.instantiateViewController(withIdentifier: "FeedNavigationController") as! UINavigationController
        
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        mainFeedController = storyBoard.instantiateViewController(withIdentifier: "HomeFeedViewController") as! MainFeedViewController
        navigationController.viewControllers = [ mainFeedController ]
        //navigationController.interactivePopGestureRecognizer?.delegate = FixBackSwipeRecognizer()
        //navigationController.interactivePopGestureRecognizer?.isEnabled = true
        
        self.openInitialAppLink = openInitialAppLink
        self.appLink = appLink
    }
    
    func start() {
        let realm = RealmManager.instance.getMemRealm()
        let categories = realm.objects(Category.self)
        mainFeedController.bindData(categories: categories)
        mainFeedController.delegate = self
        loadingState = .notLoading
        
    }
    
    func loadMainFeed() {
        print("loadMainFeed")
        let realm = RealmManager.instance.getMemRealm()
        SnipRequests.instance.getMain()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self](catList) in
                if let vc = self?.mainFeedController {
                    vc.resetExpandedSet()
                }
                try! realm.write {
                    for category in catList {
                        realm.add(category, update: true)
                    }
                }
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
    
    func resolveAndPushAppLink(url: URL) {
        let realm = RealmManager.instance.getMemRealm()
        SnipRequests.instance.getPostFromAppLink(url: url.absoluteString)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] (post) in
                guard let s = self else {
                    print("Missing TabCoordinator or MainFeedCoordinator")
                    return
                }
                try! realm.write {
                    realm.add(post, update: true)
                }
                s.showPostFromDeepLink(post: post)
            }) { (err) in
                print("Error resolving post from deep link: \(err.localizedDescription)")
                Crashlytics.sharedInstance().recordError(err)
        }
        .disposed(by: disposeBag)
    }
    
    func refreshMainFeedAfterLongBackground() {
        loadMainFeed()
        guard let main = self.mainFeedController else { return }
        main.scrollTableViewToTop()
    }
    
    func resetMainFeed() {
        loadMainFeed()
        guard let main = self.mainFeedController, let nav = self.navigationController else { return }
        navigationController.popViewController(animated: true)
        main.scrollToTop()
    }
    
    func showAppLink() {
        if self.openInitialAppLink {
            if let link = self.appLink {
                self.resolveAndPushAppLink(url: link)
                openInitialAppLink = false
                appLink = nil
            }
        }
    }
    
    func showNotificationBanner() {
        guard let vc = self.mainFeedController else { return }
        vc.showNotificationBanner()
        
    }
    
    func showPostFromDeepLink(post: Post) {
        navigationController.popToRootViewController(animated: false)
        let postDetailCoordinator = PostDetailCoordinator(navigationController: navigationController, post: post, mode: .none)
        postDetailCoordinator.start()
    }
    
    func pushDetailViewController(for post: Post, _ startComment: Bool) {
        let c = PostDetailCoordinator(navigationController: self.navigationController, post: post, mode: (startComment ? .startComment : .showComments))
        childCoordinators.append(c)
        c.start()
    }
    func openPostList(for category: Category) {
        let post_coordinator = GeneralFeedCoordinator(nav: self.navigationController, mode: .category(category: category))
        self.childCoordinators.append(post_coordinator)
        post_coordinator.start()
    }
    
    func showExpandedImage(for post: Post) {
        ExpandedImageViewController.showExpandedImage(for: post, presentingVC: mainFeedController)
    }
}

extension MainFeedCoordinator: MainFeedViewDelegate {
    func onNotificationsDenied() {
        NotificationManager.instance.userClosedNotificationBanner()
    }
    
    func onNotificationsRequested() {
        NotificationManager.instance.showNotificationAccessRequest()
    }
    
    func showExpandedImageView(for post: Post) {
        self.showExpandedImage(for: post)
    }
    
    func openInternalLink(url: URL) {
        AppLinkUtils.resolveAndPushAppLink(link: url.absoluteString, navigationController: self.navigationController)
    }
    
    func viewDidAppearForTheFirstTime() {
        if NotificationManager.instance.shouldShowNotificationRequest() {
            self.showNotificationBanner()
        }
        
        self.showAppLink()
    }
    
    func showWriterPosts(writer: User) {
        let coord = GeneralFeedCoordinator(nav: self.navigationController, mode: .writer(writer: writer))
        self.childCoordinators.append(coord)
        coord.start()
    }
    func showDetail(for post: Post, startComment: Bool) {
        pushDetailViewController(for: post, startComment)
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
