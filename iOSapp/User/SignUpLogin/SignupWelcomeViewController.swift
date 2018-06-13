//
//  SignupWelcomeViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/26/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import FacebookLogin

protocol SignupWelcomeViewDelegate: class {
    func onLoginRequested()
    func onSignupRequested()
    func onFBLoginRequested()
    func onCancel()
}

class SignupWelcomeViewController : GenericProgramViewController
{
    
    
    @IBOutlet var loginFBButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    
    @IBOutlet weak var termsAndConditionsView: UITextView!
    
    var delegate: SignupWelcomeViewDelegate!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        termsAndConditionsView.attributedText = getTermsAndConditionsString(color: UIColor.white)
        termsAndConditionsView.tintColor = UIColor.white
        setButtons()
        setCloseBarButton()
        setLogInBarButton()
    }
    
    func enableInteraction(enabled: Bool) {
        self.navigationItem.leftBarButtonItem?.isEnabled = enabled
        self.navigationItem.rightBarButtonItem?.isEnabled = enabled
        signupButton.isUserInteractionEnabled = enabled
        loginFBButton.isUserInteractionEnabled = enabled
    }
    
    func setCloseBarButton() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 44, height: 44)
        menuBtn.imageEdgeInsets = UIEdgeInsetsMake(15, 0, 15, 30)
        menuBtn.setImage(UIImage(named:"whiteCross"), for: .normal)
        menuBtn.addTarget(self, action: #selector(self.closeButtonClicked(sender:)), for: .touchUpInside)
        menuBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 44)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    func setLogInBarButton() {
        let menuBtn = UIButton(type: .custom)
        //menuBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 10.0)
        menuBtn.setTitle("Log In", for: .normal)
        menuBtn.setTitleColor(UIColor.white, for: .normal)
        menuBtn.titleLabel?.font = UIFont.latoBold(size: 16.0)
        menuBtn.addTarget(self, action: #selector(self.loginButtonClicked(sender:)), for: .touchUpInside)
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
    
    func setButtons() {
        signupButton.addTarget(self, action: #selector(signupButtonClicked(sender:)), for: .touchUpInside)
        loginFBButton.addTarget(self, action: #selector(continueWithFacebookClicked(sender:)), for: .touchUpInside)
    }
    
    @objc func closeButtonClicked(sender : UITapGestureRecognizer)
    {
        delegate.onCancel()
    }
    
    @objc func loginButtonClicked(sender : UITapGestureRecognizer)
    {
        delegate.onLoginRequested()
    }
    
    @objc func signupButtonClicked(sender : UITapGestureRecognizer)
    {
        delegate.onSignupRequested()
    }
    
    @objc func continueWithFacebookClicked(sender : UITapGestureRecognizer)
    {
        print("continue with Facebook clicked")
        delegate.onFBLoginRequested()
        /**
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self, completion: facebookResultHandler)
         **/
    }
    /**
    func facebookResultHandler(loginResult : LoginResult)
    {
        switch loginResult
        {
        case LoginResult.failed(let error):
            promptToUser(promptMessageTitle: "Unable to sign up with Facebook", promptMessageBody: "Sign up above or using the Facebook button", viewController: self)
            print(error)
        case LoginResult.cancelled:
            print("User cancelled login.")
        case LoginResult.success(_, _, let accessToken):
            var facebookLoginDataAsJson : Dictionary<String,String> = Dictionary<String,String>()
            facebookLoginDataAsJson["access_token"] = accessToken.authenticationToken
            facebookLoginDataAsJson["code"] = "null"
            
            let signupData : LoginOrSignupData = LoginOrSignupData(urlString: "rest-auth/facebook/", postJson: facebookLoginDataAsJson)
            
            WebUtils().postContentWithJsonBody(jsonString: signupData._postJson, urlString: signupData._urlString, completionHandler: completeSignupAction)
        }
    }
     **/
    /**
    func completeSignupAction(responseString: String)
    {
        WebUtils().completeSignupAction(responseString: responseString, viewController: self)
    }
     **/
    
}
