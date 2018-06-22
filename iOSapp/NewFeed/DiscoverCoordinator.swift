//
//  DiscoverCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol DiscoverCoordinatorDelegate: class {
    func onCategorySelected(category: String)
}

class DiscoverCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var discoverViewController: DiscoverViewController!
    var delegate: DiscoverCoordinatorDelegate?
    
    init() {
        discoverViewController = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "DiscoverViewController") as! DiscoverViewController
    }
    
    func start() {
        
    }
    
    
}
