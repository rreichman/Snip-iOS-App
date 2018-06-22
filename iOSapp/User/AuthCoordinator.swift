//
//  AuthCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/11/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import FacebookLogin
import RxSwift
import Crashlytics

protocol AuthCoordinatorDelegate: class {
    func onCancel()
    func onSuccessfulLogin(profile: User)
    func onSuccessfulSignup(profile: User)
}

class AuthCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var disposeBag: DisposeBag = DisposeBag()
    
    var navigationController: UINavigationController!
    var loginSignUpViewController: SignupWelcomeViewController!
    var presentingViewController: UIViewController!
    var delegate: AuthCoordinatorDelegate!
    
    var signupViewController: SignupViewController?
    var loginViewController: LoginViewController?
    
    init(presentingViewController: UIViewController) {
        navigationController = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "AccountNavigationController") as! UINavigationController
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        loginSignUpViewController = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "SignupWelcomeViewController") as! SignupWelcomeViewController
        loginSignUpViewController.delegate = self
        self.presentingViewController = presentingViewController
        navigationController.viewControllers = [ loginSignUpViewController ]
    }
    
    func start() {
        
        presentingViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func pushSignup() {
        signupViewController = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        signupViewController!.delegate = self
        navigationController.pushViewController(signupViewController!, animated: true)
    }
    
    func popSignup() {
        guard let _ = self.signupViewController else {
            return
        }
        
        navigationController.popViewController(animated: true)
        self.signupViewController = nil
    }
    
    func pushLogin() {
        loginViewController = UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController!.delegate = self
        navigationController.pushViewController(loginViewController!, animated: true)
    }
    
    func popLogin() {
        guard let _ = self.loginViewController else { return }
        navigationController.popViewController(animated: true)
        self.loginViewController = nil
    }
    
    func popSelf() {
        navigationController.dismiss(animated: true, completion: nil)
        self.navigationController = nil
        self.loginSignUpViewController = nil
        self.loginViewController = nil
        self.signupViewController = nil
        self.delegate = nil
    }
    
    func startFBLoginSignup() {
        let loginManager = LoginManager()
        loginSignUpViewController.enableInteraction(enabled: false)
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self.loginSignUpViewController) { [weak self] loginResult in
            guard let s = self else { return }
            switch loginResult {
            case LoginResult.failed(let error):
                print("Facebook's login manager returned an error \(error)")
                promptToUser(promptMessageTitle: "Unable to sign up with Facebook", promptMessageBody: "Sign up above or using the Facebook button", viewController: s.loginSignUpViewController)
                s.loginSignUpViewController.enableInteraction(enabled: true)
            case LoginResult.cancelled:
                print("User cancelled login.")
                s.loginSignUpViewController.enableInteraction(enabled: true)
            case LoginResult.success(_, _, let accessToken):
                print("fb login success")
                SnipAuthRequests.instance.postFBToken(facebookToken: accessToken.authenticationToken)
                    .flatMap({ (snip_auth_token) -> Single<User> in
                        print("POST fb token, got snip_auth_token, sending FCM notificatoin token")
                        NotificationManager.instance.sendRegistrationTokenAfterLogin()
                        return SessionManager.instance.loginFetchProfile(auth_token: snip_auth_token)
                    })
                    .observeOn(MainScheduler.instance)
                    .subscribe(onSuccess: { [weak self] (user_profile) in
                        print("Fetched user profile with auth token")
                        guard let s = self, let _ = s.loginSignUpViewController else { return }
                        s.delegate.onSuccessfulLogin(profile: user_profile)
                        s.popSelf()
                    }, onError: { (err) in
                        print("Error logging in with fb \(err)")
                        Crashlytics.sharedInstance().recordError(err)
                        guard let s = self, let vc = s.loginSignUpViewController else { return }
                        promptToUser(promptMessageTitle: "Unable to sign up with Facebook", promptMessageBody: "Sign up above or using the Facebook button", viewController: vc)
                        vc.enableInteraction(enabled: true)
                    })
                    .disposed(by: s.disposeBag)
                /**
                var facebookLoginDataAsJson : Dictionary<String,String> = Dictionary<String,String>()
                facebookLoginDataAsJson["access_token"] = accessToken.authenticationToken
                facebookLoginDataAsJson["code"] = "null"
                
                let signupData : LoginOrSignupData = LoginOrSignupData(urlString: "rest-auth/facebook/", postJson: facebookLoginDataAsJson)
                
                WebUtils().postContentWithJsonBody(jsonString: signupData._postJson, urlString: signupData._urlString, completionHandler: completeSignupAction)
                 **/
            }
        }
    }
    
    func postLogin(email: String, password: String) {
        guard let loginvc = self.loginViewController else { return }
        loginvc.enableInteraction(enabled: false)
        SnipAuthRequests.instance.postLogin(email: email, password: password)
            .flatMap({ (snip_auth_token) -> Single<User> in
                print("Successful login, fetching user profile, sending FCM notification token")
                NotificationManager.instance.sendRegistrationTokenAfterLogin()
                return SessionManager.instance.loginFetchProfile(auth_token: snip_auth_token)
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] (user_profile) in
                print("User profile fetched")
                guard let s = self, let _ = s.loginViewController else { return }
                s.delegate.onSuccessfulLogin(profile: user_profile)
                s.popSelf()
            }) { [weak self] (err) in
                print("Error logging user in\(err)")
                guard let s = self, let vc = s.loginViewController else { return }
                
                if let api_error = err as? APIError {
                    switch api_error {
                    case .badLogin(let message):
                        promptToUser(promptMessageTitle: "Error logging in", promptMessageBody: message, viewController: vc)
                    default:
                        promptToUser(promptMessageTitle: "Error logging in", promptMessageBody: "There was an error logging in, please try again", viewController: vc)
                    }
                } else {
                    Crashlytics.sharedInstance().recordError(err)
                    promptToUser(promptMessageTitle: "Error logging in", promptMessageBody: "There was an error logging in, please try again", viewController: vc)
                }
                
                vc.enableInteraction(enabled: true)
            }
            .disposed(by: self.disposeBag)
    }
    
    func postSignup(email: String, first_name: String, last_name: String, password: String) {
        guard let signupvc = self.signupViewController else { return }
        signupvc.enableInteraction(enabled: false)
        SnipAuthRequests.instance.postSignUp(email: email, first_name: first_name, last_name: last_name, password: password)
            .flatMap({ (snip_auth_token) -> Single<User> in
                print("Successful Signup, fetching user profile, sending FCM notificationToken")
                NotificationManager.instance.sendRegistrationTokenAfterLogin()
                return SessionManager.instance.loginFetchProfile(auth_token: snip_auth_token)
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] (user_profile) in
                print("User profile fetched")
                guard let s = self, let _ = s.signupViewController else { return }
                s.delegate.onSuccessfulSignup(profile: user_profile)
                s.popSelf()
            }) { [weak self] (err) in
                print("Error on user signup \(err)")
                guard let s = self, let vc = s.signupViewController else { return }
                
                if let api_error = err as? APIError {
                    switch api_error {
                    case .userAlreadyExists(let message):
                        promptToUser(promptMessageTitle: "Error Creating Account", promptMessageBody: message, viewController: vc)
                    default:
                        promptToUser(promptMessageTitle: "Error Creating Account", promptMessageBody: "There was an error creating your account, please try again", viewController: vc)
                    }
                } else {
                    Crashlytics.sharedInstance().recordError(err)
                    promptToUser(promptMessageTitle: "Error Creating Account", promptMessageBody: "There was an error creating your account, please try again", viewController: vc)
                }
                
                vc.enableInteraction(enabled: true)
            }
            .disposed(by: self.disposeBag)
    }
    
    func postPasswordReset(email: String) {
        guard let loginvc = self.loginViewController else { return }
        loginvc.enableInteraction(enabled: false)
        SnipAuthRequests.instance.postForgotPassword(email: email)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self](detail_string) in
                guard let s = self, let vc = s.loginViewController else { return }
                promptToUser(promptMessageTitle: "Password Reset", promptMessageBody: detail_string, viewController: vc)
                vc.enableInteraction(enabled: true)
            }) { [weak self] (err) in
                print("error posting pasword reset \(err)")
                guard let s = self, let vc = s.loginViewController else { return }
                if let api_err = err as? APIError {
                    switch api_err {
                    case .userDoesNotExist:
                        promptToUser(promptMessageTitle: "Password Reset", promptMessageBody: "A user with that email does not exist.", viewController: vc)
                    default:
                        promptToUser(promptMessageTitle: "Password Reset", promptMessageBody: "We encountered an error trying to reset your password.", viewController: vc)
                    }
                } else {
                    Crashlytics.sharedInstance().recordError(err)
                    promptToUser(promptMessageTitle: "Password Reset", promptMessageBody: "We encountered an error trying to reset your password.", viewController: vc)
                }
        }
    }
}

extension AuthCoordinator: SignupWelcomeViewDelegate {
    func onLoginRequested() {
        pushLogin()
    }
    
    func onSignupRequested() {
        pushSignup()
    }
    
    func onFBLoginRequested() {
        startFBLoginSignup()
    }
    
    func onCancel() {
        guard let _ = self.navigationController else { return }
        navigationController.dismiss(animated: true, completion: nil)
        self.navigationController = nil
        self.signupViewController = nil
        self.loginViewController = nil
        delegate.onCancel()
    }
}

extension AuthCoordinator: SignupViewDelegate {
    func onSignupCancel() {
        popSignup()
    }
    
    func onSignupRequested(email: String, firstName: String, lastName: String, password: String) {
        postSignup(email: email, first_name: firstName, last_name: lastName, password: password)
    }
}

extension AuthCoordinator: LoginViewDelegate {
    func onCancelLoginRequested() {
        popLogin()
    }
    
    func onLoginRequested(email: String, password: String) {
        postLogin(email: email, password: password)
    }
    
    func onForgotPasswordRequested(email: String) {
        postPasswordReset(email: email)
    }
    
    
}
