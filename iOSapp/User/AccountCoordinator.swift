//
//  AccountCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/11/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class AccountCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController!
    
    var profileViewController: ProfileViewController!
    var settingsViewController: SettingsViewController?
    
    init() {
        navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AccountNavigationController") as! UINavigationController
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        
        profileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileViewController.delegate = self
        navigationController.viewControllers = [ profileViewController ]
    }
    
    func start() {
        if SessionManager.instance.loggedIn {
            let realm = RealmManager.instance.getRealm()
            let user = realm.object(ofType: User.self, forPrimaryKey: SessionManager.instance.currentLoginUsername)
            profileViewController.bind(profile: user)
        } else {
            profileViewController.bind(profile: nil)
        }
    }
    
    func showAuthIfNeeded() {
        if !SessionManager.instance.loggedIn {
            let authCoordinator = AuthCoordinator(presentingViewController: profileViewController)
            childCoordinators.append(authCoordinator)
            navigationController.popToRootViewController(animated: true)
            authCoordinator.start()
        }
    }
    
    func pushSettingsViewController() {
        self.settingsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.settingsViewController!.delegate = self
        self.navigationController.pushViewController(self.settingsViewController!, animated: true)
    }
}

extension AccountCoordinator: ProfileViewDelegate {
    func onSettingsClicked() {
        pushSettingsViewController()
    }
    
    func viewDidAppear() {
        showAuthIfNeeded()
    }
    
    func onSavedPostsRequested() {
        // pass
    }
    
    func onMyPostsRequested() {
        // pass
    }
}

extension AccountCoordinator: SettingsViewDelegate {
    func onLogoutRequested() {
        // pass
    }
    
    func backRequested() {
        navigationController.popViewController(animated: true)
        self.settingsViewController = nil
    }
    
    
}

