//
//  SignupViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/28/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

protocol SignupViewDelegate: class {
    func onSignupCancel()
    func onSignupRequested(email: String, firstName: String, lastName: String, password: String)
}

class SignupViewController : GenericProgramViewController
{
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailSeparator: UIView!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordSeparator: UIView!
    @IBOutlet weak var showPasswordView: UITextView!
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var firstNameSeparator: UIView!
    @IBOutlet weak var firstNameWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var lastNameSeparator: UIView!
    @IBOutlet weak var lastNameViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lastNameWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var termsAndConditionsView: UITextView!
    @IBOutlet weak var termsAndConditionsLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var signUpButton: UIButton!
    
    @IBOutlet weak var bottomSurroundingViewBottomConstraint: NSLayoutConstraint!
    
    var delegate: SignupViewDelegate!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = "Sign Up".uppercased()
        
        designTextFieldHighlights()
        
        setTexts()
        
        
        emailTextField.borderStyle = UITextBorderStyle.none
        passwordTextField.borderStyle = UITextBorderStyle.none
        firstNameTextField.borderStyle = UITextBorderStyle.none
        lastNameTextField.borderStyle = UITextBorderStyle.none
        
        firstNameWidthConstraint.constant = (CachedData().getScreenWidth() - 80) / 2
        lastNameWidthConstraint.constant = (CachedData().getScreenWidth() - 80) / 2
        
        termsAndConditionsView.attributedText = LoginDesignUtils.shared.TERMS_AND_CONDITIONS_STRING
        termsAndConditionsView.tintColor = SystemVariables().TERMS_AND_CONDITIONS_COLOR
        registerForKeyboardNotifications()
        
        setButtons()
        updateConstraints()
        
        emailTextField.becomeFirstResponder()
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
        delegate.onSignupCancel()
    }
    
    func enableInteraction(enabled: Bool) {
        emailTextField.isUserInteractionEnabled = enabled
        passwordTextField.isUserInteractionEnabled = enabled
        showPasswordView.isUserInteractionEnabled = enabled
        firstNameTextField.isUserInteractionEnabled = enabled
        lastNameTextField.isUserInteractionEnabled = enabled
        signUpButton.isUserInteractionEnabled = enabled
        self.navigationItem.leftBarButtonItem?.isEnabled = enabled
    }
    
    func designTextFieldHighlights()
    {
        emailSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        passwordSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
        firstNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
        lastNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
    }
    
    func setTexts()
    {
        emailLabel.attributedText = LoginDesignUtils.shared.EMAIL_ACTIVE_STRING
        passwordLabel.attributedText = LoginDesignUtils.shared.PASSWORD_PASSIVE_STRING
        firstNameLabel.attributedText = LoginDesignUtils.shared.FIRST_NAME_PASSIVE_STRING
        lastNameLabel.attributedText = LoginDesignUtils.shared.LAST_NAME_PASSIVE_STRING
        showPasswordView.attributedText = LoginDesignUtils.shared.SHOW_TEXT
    }
    
    func setButtons()
    {
        
        let emailButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.emailButtonClicked(sender:)))
        emailTextField.isUserInteractionEnabled = true
        emailTextField.addGestureRecognizer(emailButtonClickRecognizer)
        
        let passwordButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.passwordButtonClicked(sender:)))
        passwordTextField.isUserInteractionEnabled = true
        passwordTextField.addGestureRecognizer(passwordButtonClickRecognizer)
        
        let showPasswordButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showPasswordButtonClicked(sender:)))
        showPasswordView.isUserInteractionEnabled = true
        showPasswordView.addGestureRecognizer(showPasswordButtonClickRecognizer)
        
        let firstNameButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.firstNameButtonClicked(sender:)))
        firstNameTextField.isUserInteractionEnabled = true
        firstNameTextField.addGestureRecognizer(firstNameButtonClickRecognizer)
        
        let lastNameButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.lastNameButtonClicked(sender:)))
        lastNameTextField.isUserInteractionEnabled = true
        lastNameTextField.addGestureRecognizer(lastNameButtonClickRecognizer)
        
        signUpButton.addTarget(self, action: #selector(onSignUpRequested), for: .touchUpInside)
    }
    
    @objc func onSignUpRequested() {
        if (validateRegisterData()) {
            delegate.onSignupRequested(
                email: emailTextField.text!,
                firstName: firstNameTextField.text!,
                lastName: lastNameTextField.text!,
                password: passwordTextField.text!
            )
        }
        print("signup button clicked")
    }
    
    func updateConstraints()
    {
        setConstraintToMiddleOfScreen(constraint: termsAndConditionsLeadingConstraint, view: termsAndConditionsView)
        
    }
    
    @objc func emailButtonClicked(sender : UITapGestureRecognizer)
    {
        emailTextField.becomeFirstResponder()
        colorInputBackground(nameOfDrawnInput: "email")
    }
    
    @objc func passwordButtonClicked(sender : UITapGestureRecognizer)
    {
        passwordTextField.becomeFirstResponder()
        colorInputBackground(nameOfDrawnInput: "password")
    }
    
    @objc func showPasswordButtonClicked(sender : UITapGestureRecognizer)
    {
        if (showPasswordView.text == "Hide")
        {
            passwordTextField.isSecureTextEntry = true
            showPasswordView.attributedText = LoginDesignUtils.shared.SHOW_TEXT
        }
        else
        {
            passwordTextField.isSecureTextEntry = false
            showPasswordView.attributedText = LoginDesignUtils.shared.HIDE_TEXT
        }
    }
    
    @objc func firstNameButtonClicked(sender : UITapGestureRecognizer)
    {
        firstNameTextField.becomeFirstResponder()
        colorInputBackground(nameOfDrawnInput: "firstname")
    }
    
    @objc func lastNameButtonClicked(sender : UITapGestureRecognizer)
    {
        lastNameTextField.becomeFirstResponder()
        colorInputBackground(nameOfDrawnInput: "lastname")
    }
    /**
    func completeSignupAction(responseString: String)
    {
        WebUtils().completeSignupAction(responseString: responseString, viewController: self)
    }
     **/
    
    func getSignupDataAsJson() -> Dictionary<String,String>
    {
        var signupData : Dictionary<String,String> = Dictionary<String,String>()
        signupData["email"] = emailTextField.text
        signupData["first_name"] = firstNameTextField.text
        signupData["last_name"] = lastNameTextField.text
        signupData["password1"] = passwordTextField.text
        
        return signupData
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
                
                self.bottomSurroundingViewBottomConstraint.constant = keyboardHeight + 10
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification)
    {
        
        // Note - This is supposed to smoothen the constraint update
        UIView.animate(withDuration: 1)
        {
            self.view.layoutIfNeeded()
            self.bottomSurroundingViewBottomConstraint.constant = 10
        }
    }
    
    // Note - this is an ugly implementation but at least it's fast...
    func colorInputBackground(nameOfDrawnInput : String)
    {
        if (nameOfDrawnInput == "email")
        {
            emailLabel.attributedText = LoginDesignUtils.shared.EMAIL_ACTIVE_STRING
            passwordLabel.attributedText = LoginDesignUtils.shared.PASSWORD_PASSIVE_STRING
            firstNameLabel.attributedText = LoginDesignUtils.shared.FIRST_NAME_PASSIVE_STRING
            lastNameLabel.attributedText = LoginDesignUtils.shared.LAST_NAME_PASSIVE_STRING
            
            emailSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
            passwordSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            firstNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            lastNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
        }
        else if (nameOfDrawnInput == "password")
        {
            emailLabel.attributedText = LoginDesignUtils.shared.EMAIL_PASSIVE_STRING
            passwordLabel.attributedText = LoginDesignUtils.shared.PASSWORD_ACTIVE_STRING
            firstNameLabel.attributedText = LoginDesignUtils.shared.FIRST_NAME_PASSIVE_STRING
            lastNameLabel.attributedText = LoginDesignUtils.shared.LAST_NAME_PASSIVE_STRING
            
            emailSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            passwordSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
            firstNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            lastNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
        }
        else if (nameOfDrawnInput == "firstname")
        {
            emailLabel.attributedText = LoginDesignUtils.shared.EMAIL_PASSIVE_STRING
            passwordLabel.attributedText = LoginDesignUtils.shared.PASSWORD_PASSIVE_STRING
            firstNameLabel.attributedText = LoginDesignUtils.shared.FIRST_NAME_ACTIVE_STRING
            lastNameLabel.attributedText = LoginDesignUtils.shared.LAST_NAME_PASSIVE_STRING
            
            emailSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            passwordSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            firstNameSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
            lastNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
        }
        else if (nameOfDrawnInput == "lastname")
        {
            emailLabel.attributedText = LoginDesignUtils.shared.EMAIL_PASSIVE_STRING
            passwordLabel.attributedText = LoginDesignUtils.shared.PASSWORD_PASSIVE_STRING
            firstNameLabel.attributedText = LoginDesignUtils.shared.FIRST_NAME_PASSIVE_STRING
            lastNameLabel.attributedText = LoginDesignUtils.shared.LAST_NAME_ACTIVE_STRING
            
            emailSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            passwordSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            firstNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            lastNameSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        }
    }
    
    func validateRegisterData() -> Bool
    {
        if emailTextField.text?.count == 0
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Please insert email address", viewController: self)
            return false
        }
        
        if firstNameTextField.text?.count == 0
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Please insert first name", viewController: self)
            return false
        }
        
        if lastNameTextField.text?.count == 0
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Please insert last name", viewController: self)
            return false
        }
        
        if (passwordTextField.text?.count)! == 0
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Please enter password", viewController: self)
            return false
        }
        
        if (passwordTextField.text?.count)! < SystemVariables().PASSWORD_LENGTH_LIMIT
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Password is too short", viewController: self)
            return false
        }
        
        return true
    }
}
