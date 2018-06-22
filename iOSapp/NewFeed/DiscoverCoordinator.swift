//
//  DiscoverCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit


class DiscoverCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var discoverViewController: DiscoverViewController!
    var navigationController: UINavigationController!
    
    init() {
        navigationController = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "DiscoverNavigationController") as! UINavigationController
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        discoverViewController = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "DiscoverViewController") as! DiscoverViewController
        discoverViewController.delegate = self
        discoverViewController.title = "DISCOVER"
        discoverViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func start() {
        navigationController.viewControllers =  [ discoverViewController ]
    }
    
    func pushPostListCoordinator(categoryName: String) {
        let realm = RealmManager.instance.getMemRealm()
        
        guard let category = realm.object(ofType: Category.self, forPrimaryKey: categoryName), let nav = self.navigationController else {
            print("DiscoveryCoordinator: Unable to get category from database by name")
            return
        }
        
        let generalFeedCoordinator = GeneralFeedCoordinator(nav: nav, mode: .category(category: category))
        self.childCoordinators.append(generalFeedCoordinator)
        generalFeedCoordinator.start()
    }
    
}

extension DiscoverCoordinator: DiscoverViewDelegate {
    func onCategorySelected(name: String) {
        self.pushPostListCoordinator(categoryName: name)
    }
}
