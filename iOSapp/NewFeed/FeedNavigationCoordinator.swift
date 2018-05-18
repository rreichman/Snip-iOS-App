//
//  FeedNavigationCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class FeedNavigationCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController!
    var mainFeedController: HomeFeedViewController!
    init() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        navigationController = storyBoard.instantiateViewController(withIdentifier: "FeedNavigationController") as! UINavigationController
        mainFeedController = storyBoard.instantiateViewController(withIdentifier: "HomeFeedViewController") as! HomeFeedViewController
        navigationController.viewControllers = [ mainFeedController ]
    }
    
    func start() {
        let realm = RealmManager.instance.getMemRealm()
        let categories = realm.objects(Category.self)
        mainFeedController.setCategoryList(categories: categories)
    }
    
    func loadMainFeed() {
        
    }
}
