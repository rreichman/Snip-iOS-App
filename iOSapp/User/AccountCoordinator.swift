//
//  AccountCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/11/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol AccountCoordinatorDelegate: class {
    func onCancelWithoutLoginSignup()
    func onUserLogout()
}

class AccountCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController!
    var profileViewController: ProfileViewController!
    
    var settingsViewController: SettingsViewController?
    var authCoordinator: AuthCoordinator?
    
    var delegate: AccountCoordinatorDelegate!
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
            guard let username = SessionManager.instance.currentLoginUsername else {
                print("AccountCoordinator:start() found we were logged in but SessionManager does not have a saved username")
                profileViewController.bind(profile: nil)
                //fetch it for next time
                SnipRequests.instance.buildProfile(authToken: SessionManager.instance.authToken!).subscribe()
                return
            }
            let user = realm.object(ofType: User.self, forPrimaryKey: username)
            profileViewController.bind(profile: user)
        } else {
            profileViewController.bind(profile: nil)
        }
    }
    
    func showAuthIfNeeded() {
        if !SessionManager.instance.loggedIn {
            print("No login found, pushing Login/Signup flow")
            
            //bind nil to userprofile to clear old data
            profileViewController.bind(profile: nil)
            
            self.authCoordinator = AuthCoordinator(presentingViewController: profileViewController)
            authCoordinator!.delegate = self
            childCoordinators.append(authCoordinator!)
            navigationController.popToRootViewController(animated: true)
            authCoordinator!.start()
        } else {
            print("Login found upon returning to Profile view")
            let realm = RealmManager.instance.getRealm()
            guard let username = SessionManager.instance.currentLoginUsername else {
                print("AccountCoordinator:showAuthIfNeeded() found we were logged in but SessionManager does not have a saved username")
                profileViewController.bind(profile: nil)
                return
            }
            let user = realm.object(ofType: User.self, forPrimaryKey: username)
            profileViewController.bind(profile: user)
        }
    }
    
    func popAuthCoordinator() {
        authCoordinator = nil
        childCoordinators.removeAll()
    }
    
    func pushSettingsViewController() {
        self.settingsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.settingsViewController!.delegate = self
        self.navigationController.pushViewController(self.settingsViewController!, animated: true)
    }
    
    func popSettingsViewController() {
        guard let _ = settingsViewController else { return }
        navigationController.popViewController(animated: true)
        self.settingsViewController = nil
    }
    
    func pushPostFeed(with mode: FeedMode) {
        //Sanity check
        if !SessionManager.instance.loggedIn {
            print("Show saved posts pressed but user not logged in")
            return
        }
        let generalFeedCoordinator = GeneralFeedCoordinator(nav: navigationController, mode: mode)
        generalFeedCoordinator.delegate = self
        childCoordinators.append(generalFeedCoordinator)
        generalFeedCoordinator.start()
    }
    
    func popGeneralFeedCoordinator() {
        if childCoordinators.count > 0 {
            let _ = childCoordinators.popLast()
        }
    }
    
    func logUserOut() {
        SessionManager.instance.logout()
        profileViewController.bind(profile: nil)
        popSettingsViewController()
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
        pushPostFeed(with: .savedSnips)
    }
    
    func onFavoriteSnipsRequested() {
        pushPostFeed(with: .likedSnips)
    }
}

extension AccountCoordinator: SettingsViewDelegate {
    func onLogoutRequested() {
        logUserOut()
        delegate.onUserLogout()
    }
    
    func backRequested() {
        popSettingsViewController()
    }
    
}

extension AccountCoordinator: AuthCoordinatorDelegate {
    func onSuccessfulSignup(profile: User) {
        profileViewController.bind(profile: profile)
        popAuthCoordinator()
    }
    
    func onSuccessfulLogin(profile: User) {
        profileViewController.bind(profile: profile)
        popAuthCoordinator()
    }
    
    func onCancel() {
        popAuthCoordinator()
        delegate.onCancelWithoutLoginSignup()
    }
}

extension AccountCoordinator: GeneralFeedCoordinatorDelegate {
    func onLeaveFeed() {
        popGeneralFeedCoordinator()
    }
    
    
}

