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
                        if let cached = realm.object(ofType: Category.self, forPrimaryKey: category.categoryName) {
                            category.posts.append(objectsIn: cached.posts)
                        }
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
    
    func resolveAndPushAppLink(url: URL, fromNotification: Bool) {
        var single: Single<Post>?
        let action = AppLinkUtils.routeAppLink(link: url)
        switch action {
        case .openPost(let slug):
            single = SnipRequests.instance.getPost(fromSlug: slug)
        case .followRedirect(let url):
            single = AppLinkRequests.instance.followRedirects(urlInSnipDomain: url)
                .flatMap({ (slug: String) -> Single<Post> in
                    return SnipRequests.instance.getPost(fromSlug: slug)
                })
        default:
            break
        }
        guard let postSingle = single else {
            print("MainFeedCoordinator Attempted to resolve and push app link but a slug could not be found")
            return
        }
        let realm = RealmManager.instance.getMemRealm()
        postSingle.observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] (post) in
                try! realm.write {
                    realm.add(post, update: true)
                }
                self.showPostFromDeepLink(post: post)
                
                SnipLoggerRequests.instance.logPostDeepLink(postId: post.id, fromNotification: fromNotification)
            }) { (err) in
                print("Error resolving post from deep link: \(err.localizedDescription)")
                Crashlytics.sharedInstance().recordError(err)
                
                if let apiError = err as? APIError {
                    switch apiError {
                    case .unableToResolveAppLink(let of):
                        print("Opening Safari instead")
                        UIApplication.shared.open(of, options: [:], completionHandler: nil)
                    default:
                        break
                    }
                }
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
        navigationController.popToRootViewController(animated: true)
        main.resetExpandedSet()
        main.scrollToTop()
    }
    
    func showAppLink() {
        if self.openInitialAppLink {
            if let link = self.appLink {
                self.resolveAndPushAppLink(url: link, fromNotification: false)
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
    func openPostList(for category: Category, animated: Bool = true) {
        let post_coordinator = GeneralFeedCoordinator(nav: self.navigationController, mode: .category(category: category))
        self.childCoordinators.append(post_coordinator)
        post_coordinator.start(animated: animated)
    }
    
    func showExpandedImage(for post: Post) {
        ExpandedImageViewController.showExpandedImage(for: post, presentingVC: mainFeedController)
    }
    
    func onDiscoverCategorySelected(name: String) {
        let realm = RealmManager.instance.getMemRealm()
        guard let category = realm.object(ofType: Category.self, forPrimaryKey: name), let nav = self.navigationController, let _ = self.mainFeedController else { return }
        nav.popToRootViewController(animated: false)
        self.openPostList(for: category, animated: false)
        
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
        // Not showing notifications yet
        #if MAIN
        print("Not show notification request yet")
        #else
        if NotificationManager.instance.shouldShowNotificationRequest() {
            self.showNotificationBanner()
        }
        #endif
        self.showAppLink()
    }
    
    func showWriterPosts(writer: User) {
        let coord = GeneralFeedCoordinator(nav: self.navigationController, mode: .writer(writer: writer))
        self.childCoordinators.append(coord)
        coord.start()
        
        SnipLoggerRequests.instance.logAuthorProfileView(authorUserName: writer.username)
    }
    func showDetail(for post: Post, startComment: Bool) {
        pushDetailViewController(for: post, startComment)
    }
    
    func onCategorySelected(category: Category) {
        print("\(category.categoryName) selected")
        openPostList(for: category)
        
        SnipLoggerRequests.instance.logCategoryView(categoryName: category.categoryName, fromDiscover: false)
    }
    func refreshFeed() {
        if loadingState != .loadingPage {
            loadMainFeed()
        }
    }
}
