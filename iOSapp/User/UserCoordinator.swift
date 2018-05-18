//
//  UserCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/17/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class UserCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    
    var navigationController: GenericNavigationController!
    var rootViewController: ProfileViewController!
    
    init() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        navigationController = storyboard.instantiateViewController(withIdentifier: "UserNavigationController") as! GenericNavigationController
        rootViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        navigationController.viewControllers = [ rootViewController ]
    }
    
    func start() {
        
    }
}
