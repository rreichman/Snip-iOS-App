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
        let _ = UIColor(red: 0, green: 0.7, blue: 0.8, alpha: 1.0)
        
        let feedCoordinator = MainFeedCoordinator()
        childCoordinators.append(feedCoordinator)
        feedCoordinator.navigationController.tabBarItem = UITabBarItem(title: "Home", image: #imageLiteral(resourceName: "tabBarHomeTwo"), tag: 0)
        feedCoordinator.start()
        
        let walletCoordinator = WalletCoordinator()
        childCoordinators.append(walletCoordinator)
        walletCoordinator.containerVC.tabBarItem = UITabBarItem(title: "Wallet", image: #imageLiteral(resourceName: "tabBarWallet"), tag: 1)
        walletCoordinator.start()
        
        let userCoordinator = UserCoordinator()
        childCoordinators.append(userCoordinator)
        userCoordinator.navigationController.tabBarItem = UITabBarItem(title: "Account", image: #imageLiteral(resourceName: "tabAccount"), tag: 1)
        userCoordinator.start()
        
        return [ feedCoordinator.navigationController, walletCoordinator.containerVC, userCoordinator.navigationController ]
        
    }
}

extension TabCoordinator: MainTabBarViewDelegate {
    func onTabSelected(tag: Int) {
        //pass
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
