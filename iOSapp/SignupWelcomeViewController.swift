//
//  SignupWelcomeViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/26/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import FacebookLogin

class SignupWelcomeViewController : GenericProgramViewController
{
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var loginLabel: UILabel!
    
    @IBOutlet weak var closeScreenView: UIView!
    @IBOutlet weak var goToLoginView: UIView!
    
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var commentImageLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signupMessageView: UIImageView!
    @IBOutlet weak var signUpMessageLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var takesLessThanMinuteView: UIImageView!
    @IBOutlet weak var takesLessThanMinuteLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signupWithSnipView: UIView!
    @IBOutlet weak var signUpWithSnipViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var orSeparator: UIImageView!
    @IBOutlet weak var orSeparatorLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var continueWithFacebookView: UIView!
    @IBOutlet weak var continueWithFacebookLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var termsAndConditionsView: UITextView!
    @IBOutlet weak var termsAndConditionsLeadingConstraint: NSLayoutConstraint!

    let LOGIN_STRING = NSAttributedString(string: "Log In", attributes: [NSAttributedStringKey.font : SystemVariables().LOGIN_SIGNUP_BUTTON_FONT!, NSAttributedStringKey.foregroundColor : UIColor.white])
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        updateConstraints()
        
        backgroundImage.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        continueWithFacebookView.backgroundColor = UIColor(red:0.22, green:0.35, blue:0.5, alpha:1)
        
        signupWithSnipView.layer.cornerRadius = 24
        continueWithFacebookView.layer.cornerRadius = 24
        
        termsAndConditionsView.attributedText = getTermsAndConditionsString(color: UIColor.white)
        termsAndConditionsView.tintColor = UIColor.white
        
        loginLabel.textColor = UIColor.white
        loginLabel.attributedText = LOGIN_STRING
        
        navigationController?.navigationBar.isHidden = true
        
        setButtons()
    }
    
    func updateConstraints()
    {
        setConstraintToMiddleOfScreen(constraint: commentImageLeadingConstraint, view: commentImageView)
        
        setConstraintToMiddleOfScreen(constraint: signUpMessageLeadingConstraint, view: signupMessageView)
        
        setConstraintToMiddleOfScreen(constraint: takesLessThanMinuteLeadingConstraint, view: takesLessThanMinuteView)
        
        setConstraintToMiddleOfScreen(constraint: signUpWithSnipViewLeadingConstraint, view: signupWithSnipView)
        
        setConstraintToMiddleOfScreen(constraint: orSeparatorLeadingConstraint, view: orSeparator)
        
        setConstraintToMiddleOfScreen(constraint: continueWithFacebookLeadingConstraint, view: continueWithFacebookView)

        setConstraintToMiddleOfScreen(constraint: termsAndConditionsLeadingConstraint, view: termsAndConditionsView)
    }
    
    func setButtons()
    {
        let closeButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeButtonClicked(sender:)))
        closeScreenView.isUserInteractionEnabled = true
        closeScreenView.addGestureRecognizer(closeButtonClickRecognizer)
        
        let loginButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.loginButtonClicked(sender:)))
        goToLoginView.isUserInteractionEnabled = true
        goToLoginView.addGestureRecognizer(loginButtonClickRecognizer)
        
        let signupButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.signupButtonClicked(sender:)))
        signupWithSnipView.isUserInteractionEnabled = true
        signupWithSnipView.addGestureRecognizer(signupButtonClickRecognizer)
        
        let continueWithFacebookClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.continueWithFacebookClicked(sender:)))
        continueWithFacebookView.isUserInteractionEnabled = true
        continueWithFacebookView.addGestureRecognizer(continueWithFacebookClickRecognizer)
    }
    
    @objc func closeButtonClicked(sender : UITapGestureRecognizer)
    {
        // TODO:: fix this
        goBackWithoutNavigationBar(navigationController: navigationController!, showNavigationBar: false)
        print("close button clicked")
    }
    
    @objc func loginButtonClicked(sender : UITapGestureRecognizer)
    {
        print("login button clicked")
        performSegue(withIdentifier: "showLoginSegue", sender: self)
        print("login button clicked. After segue")
    }
    
    @objc func signupButtonClicked(sender : UITapGestureRecognizer)
    {
        print("signup button clicked")
        performSegue(withIdentifier: "showSignupSegue", sender: self)
        print("signup button clicked. After segue")
    }
    
    @objc func continueWithFacebookClicked(sender : UITapGestureRecognizer)
    {
        print("continue with Facebook clicked")
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self, completion: facebookResultHandler)
    }
    
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
    
    func completeSignupAction(responseString: String)
    {
        WebUtils().completeSignupAction(responseString: responseString, viewController: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("preparing")
        let nextViewController = segue.destination as! GenericProgramViewController
        nextViewController.viewControllerToReturnTo = self.viewControllerToReturnTo
        print("done preparing")
    }
}
