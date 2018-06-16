//
//  LoginViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/27/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
protocol LoginViewDelegate: class {
    func onCancelLoginRequested()
    func onLoginRequested(email: String, password: String)
    func onForgotPasswordRequested(email: String)
}
class LoginViewController : GenericProgramViewController, UIGestureRecognizerDelegate
{
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailInputView: UITextField!
    @IBOutlet weak var emailInputViewSeparator: UIView!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordInputView: UITextField!
    @IBOutlet weak var forgotPasswordView: UITextView!
    @IBOutlet weak var forgotPasswordSurroundingView: UIView!
    
    @IBOutlet weak var passwordInputViewSeparator: UIView!
    
    @IBOutlet weak var bottomLoginLabel: UILabel!
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var loginButtonViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButtonViewBottomConstraint: NSLayoutConstraint!
    
    var inForgotPasswordProcess : Bool = false
    var inLoginProcess : Bool = false
    
    var delegate: LoginViewDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Login".uppercased()
        
        loginButtonView.layer.cornerRadius = 24
        loginButtonView.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        colorEmailInputBackground()
        
        setConstraintToMiddleOfScreen(constraint: loginButtonViewLeadingConstraint, view: loginButtonView)
        
        bottomLoginLabel.attributedText = LoginDesignUtils.shared.LOGIN_STRING_BOTTOM
        
        emailLabel.attributedText = LoginDesignUtils.shared.EMAIL_ACTIVE_STRING
        passwordLabel.attributedText = LoginDesignUtils.shared.PASSWORD_PASSIVE_STRING
        forgotPasswordView.attributedText = LoginDesignUtils.shared.FORGOT_PASSWORD_STRING
        
        setButtons()
        
        removePaddingFromTextView(textView: forgotPasswordView)
        emailInputView.borderStyle = UITextBorderStyle.none
        passwordInputView.borderStyle = UITextBorderStyle.none
        
        registerForKeyboardNotifications()
        
        emailInputView.becomeFirstResponder()
        print("end login")
        //whiteBackArrow()
    }
    
    private func whiteBackArrow() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 44, height: 44)
        menuBtn.imageEdgeInsets = UIEdgeInsetsMake(14, 0, 14, 26)
        menuBtn.setImage(UIImage(named:"whiteBackArrow"), for: .normal)
        menuBtn.addTarget(self, action: #selector(backButtonTapped), for: UIControlEvents.touchUpInside)
        menuBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 44)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    @objc func backButtonTapped() {
        delegate.onCancelLoginRequested()
    }
    
    func enableInteraction(enabled: Bool) {
        loginButtonView.isUserInteractionEnabled = enabled
        emailInputView.isUserInteractionEnabled = enabled
        passwordInputView.isUserInteractionEnabled = enabled
        forgotPasswordView.isUserInteractionEnabled = enabled
        self.navigationItem.leftBarButtonItem?.isEnabled = enabled
    }
    
    func setButtons()
    {
        
        let loginButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.loginButtonClicked(sender:)))
        loginButtonView.isUserInteractionEnabled = true
        loginButtonView.addGestureRecognizer(loginButtonClickRecognizer)
        
        let emailButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.emailButtonClicked(sender:)))
        emailInputView.isUserInteractionEnabled = true
        emailInputView.addGestureRecognizer(emailButtonClickRecognizer)
        emailButtonClickRecognizer.delegate = self
        
        let passwordButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.passwordButtonClicked(sender:)))
        passwordInputView.isUserInteractionEnabled = true
        passwordInputView.addGestureRecognizer(passwordButtonClickRecognizer)
        passwordButtonClickRecognizer.delegate = self
        
        let forgotPasswordClickRecognzier : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.forgotPasswordPressed(sender:)))
        forgotPasswordView.isUserInteractionEnabled = true
        forgotPasswordView.addGestureRecognizer(forgotPasswordClickRecognzier)
    }
    
    @objc func loginButtonClicked(sender : UITapGestureRecognizer)
    {
        if (emailInputView.text?.count == 0)
        {
            emailInputView.becomeFirstResponder()
            colorEmailInputBackground()
            promptToUser(promptMessageTitle: "", promptMessageBody: "We'll be needing an e-mail address...", viewController: self)
        }
        else if (passwordInputView.text?.count == 0)
        {
            passwordInputView.becomeFirstResponder()
            colorPasswordInputBackround()
            promptToUser(promptMessageTitle: "", promptMessageBody: "We'll be needing a password...", viewController: self)
        }
        else
        {
            delegate.onLoginRequested(email: self.emailInputView.text!, password: self.passwordInputView.text!)
            /**
            inLoginProcess = true
            print("actually login button clicked")
            let loginData : LoginOrSignupData = LoginOrSignupData(urlString: "rest-auth/login/", postJson: getLoginDataAsJson())
            WebUtils().postContentWithJsonBody(jsonString: loginData._postJson, urlString: loginData._urlString, completionHandler: completeLoginAction)
            **/
        }
        
    }
    
    @objc func emailButtonClicked(sender : UITapGestureRecognizer)
    {
        colorEmailInputBackground()
    }
    
    @objc func passwordButtonClicked(sender : UITapGestureRecognizer)
    {
        colorPasswordInputBackround()
    }

    // TODO: There's some code duplication here with the CommentsTableViewController but not too important now
    func registerForKeyboardNotifications()
    {
        //Adding notifications on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification)
    {
        if let _ = notification.userInfo {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                var info = notification.userInfo!
                var keyboardHeight : CGFloat = ((info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height)!
                
                if #available(iOS 11.0, *)
                {
                    let bottomInset = self.view.safeAreaInsets.bottom
                    keyboardHeight -= bottomInset
                }
                
                self.loginButtonViewBottomConstraint.constant = keyboardHeight + 10 // - 83 presenting as modal here, no tab offset needed
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification)
    {
        loginButtonViewBottomConstraint.constant = 10
        // Note - This is supposed to smoothen the constraint update
        UIView.animate(withDuration: 0.25)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func forgotPasswordPressed(sender: UITapGestureRecognizer)
    {
        if (!inForgotPasswordProcess)
        {
            if (emailInputView.text!.count > 0)
            {
                delegate.onForgotPasswordRequested(email: emailInputView.text!)
                /**
                inForgotPasswordProcess = true
                forgotPasswordView.attributedText = NSAttributedString(string: forgotPasswordView.text, attributes: LoginDesignUtils.shared.FORGOT_PASSWORD_ACTIVE_ATTRIBUTES)
                postResetPassword(emailString: emailInputView.text!)
                 **/
            }
            else
            {
                emailInputView.becomeFirstResponder()
                colorEmailInputBackground()
                
                promptToUser(promptMessageTitle: "", promptMessageBody: "We'll be needing an e-mail address...", viewController: self)
            }
        }
    }
    
    func colorEmailInputBackground()
    {
        emailInputViewSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        passwordInputViewSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
        
        emailLabel.attributedText = LoginDesignUtils.shared.EMAIL_ACTIVE_STRING
        passwordLabel.attributedText = LoginDesignUtils.shared.PASSWORD_PASSIVE_STRING
    }
    
    func colorPasswordInputBackround()
    {
        emailInputViewSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
        passwordInputViewSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        emailLabel.attributedText = LoginDesignUtils.shared.EMAIL_PASSIVE_STRING
        passwordLabel.attributedText = LoginDesignUtils.shared.PASSWORD_ACTIVE_STRING
    }
    
    func postResetPassword(emailString: String)
    {
        var postResetUrlString : String = SystemVariables().URL_STRING
        postResetUrlString.append("rest-auth/password/reset/")
        
        WebUtils().postContentWithJsonBody(jsonString : ["email" : emailString], urlString : postResetUrlString, completionHandler : handleForgotResponseString)
    }
    
    func handleForgotResponseString(responseString: String)
    {
        if let jsonObj = try? JSONSerialization.jsonObject(with: responseString.data(using: .utf8)!, options: .allowFragments) as! [String : Any]
        {
            DispatchQueue.main.async
            {
                if jsonObj.keys.contains("detail")
                {
                    promptToUser(promptMessageTitle: "Password reset e-mail has been sent.", promptMessageBody: "Check your inbox to get the new password", viewController: self, completionHandler: nil)
                }
                else
                {
                    let errorMessageString : String = getErrorMessageFromResponse(jsonObj: jsonObj)
                    promptToUser(promptMessageTitle: "Error", promptMessageBody: errorMessageString, viewController: self)
                }
            }
        }
        else
        {
            // TODO: What happens here?
        }
        
        inForgotPasswordProcess = false
        DispatchQueue.main.async
        {
            self.forgotPasswordView.attributedText = NSAttributedString(string: self.forgotPasswordView.text, attributes: LoginDesignUtils().FORGOT_PASSWORD_ATTRIBUTES)
        }
    }
    
    func getLoginDataAsJson() -> Dictionary<String,String>
    {
        var loginData : Dictionary<String,String> = Dictionary<String,String>()
        
        loginData["email"] = emailInputView.text
        loginData["password"] = passwordInputView.text
        
        return loginData
    }
    /**
    func completeLoginAction(responseString: String)
    {
        if let jsonObj = try? JSONSerialization.jsonObject(with: responseString.data(using: .utf8)!, options: .allowFragments) as! [String : Any]
        {
            DispatchQueue.main.async
                {
                    if jsonObj.keys.contains("key")
                    {
                        storeUserAuthenticationToken(authenticationToken: jsonObj["key"] as! String)
                        SessionManager.instance.oldAuthProxy(token: jsonObj["key"] as! String)
                        UserInformation().getUserInformationFromWeb()
                        
                        if (self.viewControllerToReturnTo is ProfileViewController)
                        {
                            //(self.viewControllerToReturnTo as! ProfileViewController).setUsername()
                        }
                        promptToUserWithAutoDismiss(promptMessageTitle: "Login successful!", promptMessageBody: "", viewController: self, lengthInSeconds: 1, completionHandler: self.segueBackToContent)
                    }
                    else if jsonObj.keys.count == 1 && jsonObj.keys.contains("non_field_errors")
                    {
                        promptToUser(promptMessageTitle: "Something's wrong with the submitted credentails", promptMessageBody: "Please try again or recover password below", viewController: self, completionHandler: nil)
                    }
                    else
                    {
                        let errorMessageString : String = getErrorMessageFromResponse(jsonObj: jsonObj)
                        promptToUser(promptMessageTitle: "Error", promptMessageBody: errorMessageString, viewController: self)
                    }
            }
        }
        else
        {
            // TODO: answer this
            print("what to do here?")
        }
        
        inLoginProcess = false
    }
    **/
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}
