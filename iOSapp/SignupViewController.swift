//
//  SignupViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/28/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

class SignupViewController : GenericProgramViewController
{
    @IBOutlet weak var headlineView: UIView!
    
    @IBOutlet weak var closeButtonView: UIView!
    
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var headlineLabelTrailingConstraint: NSLayoutConstraint!
    
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
    
    @IBOutlet weak var bottomSignupLabel: UILabel!
    @IBOutlet weak var bottomSurroundingView: UIView!
    @IBOutlet weak var bottomSurroundingViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSurroundingViewBottomConstraint: NSLayoutConstraint!
    
    let EMAIL_ACTIVE_STRING : NSAttributedString = NSAttributedString(string: "Email", attributes: LoginDesignUtils().LABEL_ACTIVE_ATTRIBUTES)
    let EMAIL_PASSIVE_STRING : NSAttributedString = NSAttributedString(string: "Email", attributes: LoginDesignUtils().LABEL_PASSIVE_ATTRIBUTES)
    let PASSWORD_ACTIVE_STRING : NSAttributedString = NSAttributedString(string: "Password", attributes: LoginDesignUtils().LABEL_ACTIVE_ATTRIBUTES)
    let PASSWORD_PASSIVE_STRING : NSAttributedString = NSAttributedString(string: "Password", attributes: LoginDesignUtils().LABEL_PASSIVE_ATTRIBUTES)
    let FIRST_NAME_ACTIVE_STRING : NSAttributedString = NSAttributedString(string: "First Name", attributes: LoginDesignUtils().LABEL_ACTIVE_ATTRIBUTES)
    let FIRST_NAME_PASSIVE_STRING : NSAttributedString = NSAttributedString(string: "First Name", attributes: LoginDesignUtils().LABEL_PASSIVE_ATTRIBUTES)
    let LAST_NAME_ACTIVE_STRING : NSAttributedString = NSAttributedString(string: "Last Name", attributes: LoginDesignUtils().LABEL_ACTIVE_ATTRIBUTES)
    let LAST_NAME_PASSIVE_STRING : NSAttributedString = NSAttributedString(string: "Last Name", attributes: LoginDesignUtils().LABEL_PASSIVE_ATTRIBUTES)
    let SHOW_TEXT = NSAttributedString(string: "Show", attributes: LoginDesignUtils().FORGOT_PASSWORD_ATTRIBUTES)
    let HIDE_TEXT = NSAttributedString(string: "Hide", attributes: LoginDesignUtils().FORGOT_PASSWORD_ATTRIBUTES)
    
    let SIGNUP_TEXT = NSAttributedString(string: "Sign Up", attributes: LoginDesignUtils().HEADLINE_ATTRIBUTES)
    
    let TERMS_AND_CONDITIONS_STRING = getTermsAndConditionsString(color: SystemVariables().TERMS_AND_CONDITIONS_COLOR)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        headlineView.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        headlineLabel.attributedText = SIGNUP_TEXT
        bottomSignupLabel.attributedText = headlineLabel.attributedText
        
        designTextFieldHighlights()
        
        setTexts()
        
        bottomSurroundingView.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        bottomSurroundingView.layer.cornerRadius = 24
        
        emailTextField.borderStyle = UITextBorderStyle.none
        passwordTextField.borderStyle = UITextBorderStyle.none
        firstNameTextField.borderStyle = UITextBorderStyle.none
        lastNameTextField.borderStyle = UITextBorderStyle.none
        
        firstNameWidthConstraint.constant = (CachedData().getScreenWidth() - 80) / 2
        lastNameWidthConstraint.constant = (CachedData().getScreenWidth() - 80) / 2
        
        termsAndConditionsView.attributedText = TERMS_AND_CONDITIONS_STRING
        termsAndConditionsView.tintColor = SystemVariables().TERMS_AND_CONDITIONS_COLOR
        registerForKeyboardNotifications()
        
        setButtons()
        updateConstraints()
        
        emailTextField.becomeFirstResponder()
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
        emailLabel.attributedText = EMAIL_ACTIVE_STRING
        passwordLabel.attributedText = PASSWORD_PASSIVE_STRING
        firstNameLabel.attributedText = FIRST_NAME_PASSIVE_STRING
        lastNameLabel.attributedText = LAST_NAME_PASSIVE_STRING
        showPasswordView.attributedText = SHOW_TEXT
    }
    
    func setButtons()
    {
        let closeButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeButtonClicked(sender:)))
        closeButtonView.isUserInteractionEnabled = true
        closeButtonView.addGestureRecognizer(closeButtonClickRecognizer)
        
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
        
        let signupButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.signupButtonClicked(sender:)))
        bottomSurroundingView.isUserInteractionEnabled = true
        bottomSurroundingView.addGestureRecognizer(signupButtonClickRecognizer)
    }
    
    func updateConstraints()
    {
        setConstraintToMiddleOfScreen(constraint: headlineLabelTrailingConstraint, view: headlineLabel)
        
        setConstraintToMiddleOfScreen(constraint: termsAndConditionsLeadingConstraint, view: termsAndConditionsView)
        
        setConstraintToMiddleOfScreen(constraint: bottomSurroundingViewLeadingConstraint, view: bottomSurroundingView)
    }
    
    @objc func closeButtonClicked(sender : UITapGestureRecognizer)
    {
        print("signup close button clicked")
        goBackWithoutNavigationBar(navigationController: navigationController!, showNavigationBar: false)
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
            showPasswordView.attributedText = SHOW_TEXT
        }
        else
        {
            passwordTextField.isSecureTextEntry = false
            showPasswordView.attributedText = HIDE_TEXT
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
    
    @objc func signupButtonClicked(sender : UITapGestureRecognizer)
    {
        if (validateRegisterData())
        {
            let signupData = LoginOrSignupData(urlString: "rest-auth/registration/", postJson: getSignupDataAsJson())
            WebUtils().postContentWithJsonBody(jsonString: signupData._postJson, urlString: signupData._urlString, completionHandler: completeSignupAction)
        }
        print("signup button clicked")
    }
    
    func completeSignupAction(responseString: String)
    {
        WebUtils().completeSignupAction(responseString: responseString, viewController: self)
    }
    
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
        var info = notification.userInfo!
        let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height
        bottomSurroundingViewBottomConstraint.constant = 15 + keyboardHeight!
        // Note - This is supposed to smoothen the constraint update
        UIView.animate(withDuration: 1)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification)
    {
        bottomSurroundingViewBottomConstraint.constant = 15
        // Note - This is supposed to smoothen the constraint update
        UIView.animate(withDuration: 1)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    // Note - this is an ugly implementation but at least it's fast...
    func colorInputBackground(nameOfDrawnInput : String)
    {
        if (nameOfDrawnInput == "email")
        {
            emailLabel.attributedText = EMAIL_ACTIVE_STRING
            passwordLabel.attributedText = PASSWORD_PASSIVE_STRING
            firstNameLabel.attributedText = FIRST_NAME_PASSIVE_STRING
            lastNameLabel.attributedText = LAST_NAME_PASSIVE_STRING
            
            emailSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
            passwordSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            firstNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            lastNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
        }
        else if (nameOfDrawnInput == "password")
        {
            emailLabel.attributedText = EMAIL_PASSIVE_STRING
            passwordLabel.attributedText = PASSWORD_ACTIVE_STRING
            firstNameLabel.attributedText = FIRST_NAME_PASSIVE_STRING
            lastNameLabel.attributedText = LAST_NAME_PASSIVE_STRING
            
            emailSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            passwordSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
            firstNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            lastNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
        }
        else if (nameOfDrawnInput == "firstname")
        {
            emailLabel.attributedText = EMAIL_PASSIVE_STRING
            passwordLabel.attributedText = PASSWORD_PASSIVE_STRING
            firstNameLabel.attributedText = FIRST_NAME_ACTIVE_STRING
            lastNameLabel.attributedText = LAST_NAME_PASSIVE_STRING
            
            emailSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            passwordSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
            firstNameSeparator.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
            lastNameSeparator.backgroundColor = SystemVariables().UNDERLINE_DEFAULT_COLOR
        }
        else if (nameOfDrawnInput == "lastname")
        {
            emailLabel.attributedText = EMAIL_PASSIVE_STRING
            passwordLabel.attributedText = PASSWORD_PASSIVE_STRING
            firstNameLabel.attributedText = FIRST_NAME_PASSIVE_STRING
            lastNameLabel.attributedText = LAST_NAME_ACTIVE_STRING
            
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
