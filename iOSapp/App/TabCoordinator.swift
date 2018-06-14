//
//  TabCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/17/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Realm
import RxSwift
import Crashlytics

protocol FeedView: class {
    func scrollToTop()
}

class TabCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var tabController: MainTabBarViewController!
    var presentingViewController: UIViewController!
    var disposeBag = DisposeBag()
    var mainFeedNavigationController: UINavigationController!
    var mainFeedCoordinator: MainFeedCoordinator?
    init(_ presenting: UIViewController) {
        self.presentingViewController = presenting
    }
    
    func start() {
        tabController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarViewController") as! MainTabBarViewController
        tabController._delegate = self
        tabController.viewControllers = buildTabBarControllers()
        
        presentingViewController.present(tabController, animated: true, completion: nil)
    }
    
    func buildTabBarControllers() -> [UIViewController] {
        let _ = UIColor(red: 0, green: 0.7, blue: 0.8, alpha: 1.0)
        
        let feedCoordinator = MainFeedCoordinator()
        self.mainFeedCoordinator = feedCoordinator
        childCoordinators.append(feedCoordinator)
        feedCoordinator.navigationController.tabBarItem = UITabBarItem(title: "Home", image: #imageLiteral(resourceName: "tabBarHomeTwo"), tag: 0)
        feedCoordinator.start()
        
        mainFeedNavigationController = feedCoordinator.navigationController
        
        let walletCoordinator = WalletCoordinator()
        childCoordinators.append(walletCoordinator)
        walletCoordinator.containerVC.tabBarItem = UITabBarItem(title: "Wallet", image: #imageLiteral(resourceName: "tabBarWallet"), tag: 1)
        walletCoordinator.start()
        
        let accountCoordinator = AccountCoordinator()
        accountCoordinator.delegate = self
        childCoordinators.append(accountCoordinator)
        accountCoordinator.navigationController.tabBarItem = UITabBarItem(title: "Account", image: #imageLiteral(resourceName: "tabAccount"), tag: 1)
        accountCoordinator.start()
        
        return [ feedCoordinator.navigationController, walletCoordinator.containerVC, accountCoordinator.navigationController ]
        
    }
    
    func showPostFromDeepLink(url: String) {
        let realm = RealmManager.instance.getMemRealm()
        SnipRequests.instance.getPostFromAppLink(url: url)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] (post) in
                guard let s = self, let main = s.mainFeedCoordinator else {
                    print("Missing TabCoordinator or MainFeedCoordinator")
                    return
                }
                try! realm.write {
                    realm.add(post, update: true)
                }
                main.showPostFromDeepLink(post: post)
            }) { (err) in
                print("Error resolving post from deep link: \(err.localizedDescription)")
                Crashlytics.sharedInstance().recordError(err)
        }
    }
}

extension TabCoordinator: MainTabBarViewDelegate {
    func onTabSelected(tag: Int) {
        if let feed = mainFeedNavigationController.topViewController as? FeedView {
            if tabController.selectedIndex == 0 && tag == 0 {
                feed.scrollToTop()
            }
        }
    }
}

extension TabCoordinator: AccountCoordinatorDelegate {
    func onUserLogout() {
        // Jump back to home tab when the user logs out
        tabController.selectedIndex = 0
    }
    
    func onCancelWithoutLoginSignup() {
        // Jump back to home tab when user decides not to login or signup
        tabController.selectedIndex = 0
    }
}

extension UIImage {
    func tinted(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        color.set()
        withRenderingMode(.alwaysTemplate)
            .draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
