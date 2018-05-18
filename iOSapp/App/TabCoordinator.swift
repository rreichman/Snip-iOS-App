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

class TabCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var tabController: MainTabBarViewController!
    var presentingViewController: UIViewController!
    
    var mainFeedNavigationController: UINavigationController!
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
        
        let feedCoordinator = FeedNavigationCoordinator()
        childCoordinators.append(feedCoordinator)
        feedCoordinator.navigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 0)
        feedCoordinator.start()
        
        let walletCoordinator = WalletCoordinator()
        childCoordinators.append(walletCoordinator)
        walletCoordinator.containerVC.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 1)
        walletCoordinator.start()
        
        let userCoordinator = UserCoordinator()
        childCoordinators.append(userCoordinator)
        userCoordinator.navigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 2)
        userCoordinator.start()
        
        return [ feedCoordinator.navigationController, walletCoordinator.containerVC, userCoordinator.navigationController ]
        
    }
}

extension TabCoordinator: MainTabBarViewDelegate {
    func onTabSelected(tag: Int) {
        //pass
    }
}
