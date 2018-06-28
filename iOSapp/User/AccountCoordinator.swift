//
//  AccountCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/11/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Crashlytics

protocol AccountCoordinatorDelegate: class {
    func onCancelWithoutLoginSignup()
    func onUserLogout()
    func onUserLogin()
}

class AccountCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController!
    var profileViewController: ProfileViewController!
    
    var settingsViewController: SettingsViewController?
    var authCoordinator: AuthCoordinator?
    var disposeBag = DisposeBag()
    var delegate: AccountCoordinatorDelegate!
    init() {
        navigationController = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "AccountNavigationController") as! UINavigationController
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        
        profileViewController = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileViewController.delegate = self
        navigationController.viewControllers = [ profileViewController ]
    }
    
    func start() {
        if SessionManager.instance.loggedIn {
            let realm = RealmManager.instance.getRealm()
            guard let username = SessionManager.instance.currentLoginUsername else {
                print("AccountCoordinator:start() found we were logged in but SessionManager does not have a saved username")
                profileViewController.bindData(user: nil)
                //fetch it for next time
                SnipRequests.instance.fetchAndSaveLoggedInUser()
                return
            }
            let user = realm.object(ofType: User.self, forPrimaryKey: username)
            profileViewController.bindData(user: user)
        } else {
            profileViewController.bindData(user: nil)
        }
    }
    
    func showAuthIfNeeded() {
        if !SessionManager.instance.loggedIn {
            print("No login found, pushing Login/Signup flow")
            
            //bind nil to userprofile to clear old data
            profileViewController.bindData(user: nil)
            
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
                profileViewController.bindData(user: nil)
                return
            }
            let user = realm.object(ofType: User.self, forPrimaryKey: username)
            profileViewController.bindData(user: user)
        }
    }
    
    func popAuthCoordinator() {
        authCoordinator = nil
        childCoordinators.removeAll()
    }
    
    func pushSettingsViewController() {
        self.settingsViewController = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
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
        profileViewController.bindData(user: nil)
        popSettingsViewController()
        delegate.onUserLogout()
        
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
    }
    
    func backRequested() {
        popSettingsViewController()
    }
    
}

extension AccountCoordinator: AuthCoordinatorDelegate {
    func onSuccessfulSignup(profile: User) {
        profileViewController.bindData(user: profile)
        popAuthCoordinator()
        delegate.onUserLogin()
    }
    
    func onSuccessfulLogin(profile: User) {
        profileViewController.bindData(user: profile)
        popAuthCoordinator()
        delegate.onUserLogin()
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

