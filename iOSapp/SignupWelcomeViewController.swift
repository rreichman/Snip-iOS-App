//
//  SignupWelcomeViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/26/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var termsAndConditionsView: UIImageView!
    @IBOutlet weak var termsAndConditionsLeadingConstraint: NSLayoutConstraint!
    
    let LOGIN_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().LOGIN_SIGNUP_BUTTON_FONT!, NSAttributedStringKey.foregroundColor : UIColor.white]
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        updateConstraints()
        
        backgroundImage.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        continueWithFacebookView.backgroundColor = UIColor(red:0.22, green:0.35, blue:0.5, alpha:1)
        
        signupWithSnipView.layer.cornerRadius = 24
        continueWithFacebookView.layer.cornerRadius = 24
        
        loginLabel.textColor = UIColor.white
        loginLabel.attributedText = NSAttributedString(string: loginLabel.text!, attributes: LOGIN_ATTRIBUTES)
        
        navigationController?.navigationBar.isHidden = true
        
        setButtons()
    }
    
    func updateConstraints()
    {
        setLeadingConstraintInMiddleOfScreen(leadingConstraint: commentImageLeadingConstraint, view: commentImageView)
        
        setLeadingConstraintInMiddleOfScreen(leadingConstraint: signUpMessageLeadingConstraint, view: signupMessageView)
        
        setLeadingConstraintInMiddleOfScreen(leadingConstraint: takesLessThanMinuteLeadingConstraint, view: takesLessThanMinuteView)
            
        setLeadingConstraintInMiddleOfScreen(leadingConstraint: signUpWithSnipViewLeadingConstraint, view: signupWithSnipView)
        
        setLeadingConstraintInMiddleOfScreen(leadingConstraint: orSeparatorLeadingConstraint, view: orSeparator)
        
        setLeadingConstraintInMiddleOfScreen(leadingConstraint: continueWithFacebookLeadingConstraint, view: continueWithFacebookView)

        setLeadingConstraintInMiddleOfScreen(leadingConstraint: termsAndConditionsLeadingConstraint, view: termsAndConditionsView)
    }
    
    func setLeadingConstraintInMiddleOfScreen(leadingConstraint : NSLayoutConstraint, view : UIView)
    {
        leadingConstraint.constant = CachedData().getScreenWidth() / 2 - view.frame.width / 2
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
        
        let continueWithFBClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.continueWithFacebookClicked(sender:)))
        continueWithFacebookView.isUserInteractionEnabled = true
        continueWithFacebookView.addGestureRecognizer(continueWithFBClickRecognizer)
        
        let termsAndConditionsClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.termsAndConditionsClicked(sender:)))
        termsAndConditionsView.isUserInteractionEnabled = true
        termsAndConditionsView.addGestureRecognizer(termsAndConditionsClickRecognizer)
    }
    
    @objc func closeButtonClicked(sender : UITapGestureRecognizer)
    {
        goBackWithoutNavigationBar(navigationController: navigationController!, showNavigationBar: true)
        print("close button clicked")
    }
    
    @objc func loginButtonClicked(sender : UITapGestureRecognizer)
    {
        // TODO:: implement
        print("login button clicked")
    }
    
    @objc func signupButtonClicked(sender : UITapGestureRecognizer)
    {
        // TODO:: implement
        print("signup button clicked")
    }
    
    @objc func continueWithFacebookClicked(sender : UITapGestureRecognizer)
    {
        // TODO:: implement
        print("continue with FB clicked")
    }
    
    @objc func termsAndConditionsClicked(sender : UITapGestureRecognizer)
    {
        // TODO:: implement
        print("open terms and conditions")
    }
}
