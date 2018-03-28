//
//  LoginViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/27/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

class LoginViewController : GenericProgramViewController, UIGestureRecognizerDelegate
{
    @IBOutlet weak var closeScreenView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var loginImageView: UIImageView!
    @IBOutlet weak var loginTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailInputView: UITextField!
    @IBOutlet weak var emailInputViewSeparator: UIView!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordInputView: UITextField!
    @IBOutlet weak var forgotPasswordView: UITextView!
    @IBOutlet weak var forgotPasswordSurroundingView: UIView!
    
    @IBOutlet weak var passwordInputViewSeparator: UIView!
    
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var loginButtonViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButtonViewBottomConstraint: NSLayoutConstraint!
    
    var inForgotPasswordProcess : Bool = false
    var inLoginProcess : Bool = false
    
    let LABEL_PASSIVE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().LOGIN_LABEL_FONT!, NSAttributedStringKey.foregroundColor : UIColor(red:0.61, green:0.61, blue:0.61, alpha:1)]
    
    let LABEL_ACTIVE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().LOGIN_LABEL_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR]
    
    let FORGOT_PASSWORD_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().FORGOT_PASSWORD_FONT!, NSAttributedStringKey.foregroundColor : UIColor(red:0.61, green:0.61, blue:0.61, alpha:1)]
    let FORGOT_PASSWORD_ACTIVE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().FORGOT_PASSWORD_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR]
    
    let UNDERLINE_DEFAULT_COLOR = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loginButtonView.layer.cornerRadius = 24
        
        headerView.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        loginButtonView.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        emailInputViewSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        passwordInputViewSeparator.backgroundColor = UNDERLINE_DEFAULT_COLOR
        
        setConstraintToMiddleOfScreen(constraint: loginTrailingConstraint, view: loginImageView)
        setConstraintToMiddleOfScreen(constraint: loginButtonViewLeadingConstraint, view: loginButtonView)
        
        emailLabel.attributedText = NSAttributedString(string: "Email", attributes: LABEL_ACTIVE_ATTRIBUTES)
        passwordLabel.attributedText = NSAttributedString(string: "Password", attributes: LABEL_PASSIVE_ATTRIBUTES)
        forgotPasswordView.attributedText = NSAttributedString(string: "Forgot?", attributes: FORGOT_PASSWORD_ATTRIBUTES)
        
        setButtons()
        
        removePaddingFromTextView(textView: forgotPasswordView)
        emailInputView.borderStyle = UITextBorderStyle.none
        passwordInputView.borderStyle = UITextBorderStyle.none
        
        registerForKeyboardNotifications()
        
        emailInputView.becomeFirstResponder()
    }
    
    func setButtons()
    {
        let closeButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeButtonClicked(sender:)))
        closeScreenView.isUserInteractionEnabled = true
        closeScreenView.addGestureRecognizer(closeButtonClickRecognizer)
        
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
    
    @objc func closeButtonClicked(sender : UITapGestureRecognizer)
    {
        print("login close button clicked")
        goBackWithoutNavigationBar(navigationController: navigationController!, showNavigationBar: false)
    }
    
    @objc func loginButtonClicked(sender : UITapGestureRecognizer)
    {
        if (!inLoginProcess)
        {
            inLoginProcess = true
            print("actually login button clicked")
            let loginData : LoginOrSignupData = LoginOrSignupData(urlString: "rest-auth/login/", postJson: getLoginDataAsJson())
            WebUtils().postContentWithJsonBody(jsonString: loginData._postJson, urlString: loginData._urlString, completionHandler: completeLoginAction)
        }
    }
    
    @objc func emailButtonClicked(sender : UITapGestureRecognizer)
    {
        emailLabel.attributedText = NSAttributedString(string: emailLabel.text!, attributes: LABEL_ACTIVE_ATTRIBUTES)
        passwordLabel.attributedText = NSAttributedString(string: passwordLabel.text!, attributes: LABEL_PASSIVE_ATTRIBUTES)
        
        emailInputViewSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        passwordInputViewSeparator.backgroundColor = UNDERLINE_DEFAULT_COLOR
    }
    
    @objc func passwordButtonClicked(sender : UITapGestureRecognizer)
    {
        emailLabel.attributedText = NSAttributedString(string: emailLabel.text!, attributes: LABEL_PASSIVE_ATTRIBUTES)
        passwordLabel.attributedText = NSAttributedString(string: passwordLabel.text!, attributes: LABEL_ACTIVE_ATTRIBUTES)
        
        emailInputViewSeparator.backgroundColor = UNDERLINE_DEFAULT_COLOR
        passwordInputViewSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    // TODO:: either remove this or implement it (including in class)
    func textViewDidChange(_ textView: UITextView)
    {
        print("text view changed")
        /*if let placeholderLabel = textView.viewWithTag(TEXTVIEW_PLACEHOLDER_TAG) as? UILabel
        {
            placeholderLabel.isHidden = textView.attributedText.length > 0
        }*/
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
        var info = notification.userInfo!
        let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height
        loginButtonViewBottomConstraint.constant = 15 + keyboardHeight!
        // Note - This is supposed to smoothen the constraint update
        UIView.animate(withDuration: 1)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification)
    {
        loginButtonViewBottomConstraint.constant = 15
        // Note - This is supposed to smoothen the constraint update
        UIView.animate(withDuration: 1)
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
                inForgotPasswordProcess = true
                forgotPasswordView.attributedText = NSAttributedString(string: forgotPasswordView.text, attributes: FORGOT_PASSWORD_ACTIVE_ATTRIBUTES)
                postResetPassword(emailString: emailInputView.text!)
            }
            else
            {
                promptToUser(promptMessageTitle: "Unable to send Recover E-mail", promptMessageBody: "Please enter e-mail address", viewController: self)
            }
        }
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
                    // TODO:: getting bad response string!
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
            self.forgotPasswordView.attributedText = NSAttributedString(string: self.forgotPasswordView.text, attributes: self.FORGOT_PASSWORD_ATTRIBUTES)
        }
    }
    
    func getLoginDataAsJson() -> Dictionary<String,String>
    {
        var loginData : Dictionary<String,String> = Dictionary<String,String>()
        
        loginData["email"] = emailInputView.text
        loginData["password"] = passwordInputView.text
        
        return loginData
    }
    
    func completeLoginAction(responseString: String)
    {
        if let jsonObj = try? JSONSerialization.jsonObject(with: responseString.data(using: .utf8)!, options: .allowFragments) as! [String : Any]
        {
            DispatchQueue.main.async
                {
                    if jsonObj.keys.count == 1 && jsonObj.keys.contains("key")
                    {
                        storeUserAuthenticationToken(authenticationToken: jsonObj["key"] as! String)
                        UserInformation().getUserInformationFromWeb()
                        
                        promptToUser(promptMessageTitle: "Login successful!", promptMessageBody: "", viewController: self, completionHandler: self.segueBackToContent)
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
}
