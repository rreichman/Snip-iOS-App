//
//  AuthCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/11/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class AuthCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    
    var navigationController: UINavigationController!
    var loginSignUpViewController: SignupWelcomeViewController!
    var presentingViewController: UIViewController!
    init(presentingViewController: UIViewController) {
        navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AccountNavigationController") as! UINavigationController
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        loginSignUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupWelcomeViewController") as! SignupWelcomeViewController
        loginSignUpViewController.delegate = self
        self.presentingViewController = presentingViewController
        navigationController.viewControllers = [ loginSignUpViewController ]
    }
    
    func start() {
        
        presentingViewController.present(navigationController, animated: true, completion: nil)
    }
}

extension AuthCoordinator: SignupWelcomeViewDelegate {
    func onLoginRequested() {
        //pass
    }
    
    func onSignupRequested() {
        //pass
    }
    
    func onFBLoginRequested() {
        //pass
    }
    
    func onCancel() {
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    
}
