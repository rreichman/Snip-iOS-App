//
//  LoginViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/30/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginViewController : GenericProgramViewController
{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginWithFacebookButton: UIImageView!
    
    @IBOutlet weak var termsAndConditionsBox: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Making the "Back" button black instead of blue
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        emailTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderWidth = 0.5
        
        self.view.backgroundColor = SystemVariables().LOGIN_BACKGROUND_COLOR
        loginButton.backgroundColor = SystemVariables().LOGIN_BUTTON_COLOR
        
        termsAndConditionsBox.backgroundColor = SystemVariables().LOGIN_BACKGROUND_COLOR
        termsAndConditionsBox.attributedText = getTermsAndConditionsString()
        
        // TODO: this is code copying from SignupViewController. Should fix but not now
        let singleTapRecognizerFacebookLogin : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(facebookLoginPressed(sender:)))
        loginWithFacebookButton.isUserInteractionEnabled = true
        loginWithFacebookButton.addGestureRecognizer(singleTapRecognizerFacebookLogin)
    }
    
    // TODO: this is code copying from SignupViewController. Should fix but not now
    @objc func facebookLoginPressed(sender: UITapGestureRecognizer)
    {
        let loginManager = LoginManager()
        //loginManager.loginBehavior = .native
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self, completion: facebookResultHandler)
    }
    
    // TODO: this is code copying from SignupViewController. Should fix but not now
    func facebookResultHandler(loginResult : LoginResult)
    {
        switch loginResult
        {
        case LoginResult.failed(let error):
            print(error)
            promptToUser(promptMessageTitle: "Unable to log in with Facebook", promptMessageBody: "Log in above or using the Facebook button", viewController: self)
        case LoginResult.cancelled:
            print("User cancelled login.")
        case LoginResult.success(_, _, let accessToken):
            var facebookLoginDataAsJson : Dictionary<String,String> = Dictionary<String,String>()
            facebookLoginDataAsJson["access_token"] = accessToken.authenticationToken
            facebookLoginDataAsJson["code"] = "null"
            let loginData : LoginOrSignupData = LoginOrSignupData(urlString: "rest-auth/facebook/", postJson: facebookLoginDataAsJson)
            WebUtils().runFunctionAfterGettingCsrfToken(functionData: loginData, completionHandler: self.performLoginAction)
            
            print("Login is successful!")
        }
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
            // TODO:: answer this
            print("what to do here?")
        }
    }
    
    func getLoginDataAsJson() -> Dictionary<String,String>
    {
        var loginData : Dictionary<String,String> = Dictionary<String,String>()
        
        loginData["email"] = emailTextField.text
        loginData["password"] = passwordTextField.text
        
        return loginData
    }
    
    func performLoginAction(handlerParams : Any, csrfToken : String)
    {
        let loginData : LoginOrSignupData = handlerParams as! LoginOrSignupData
        WebUtils().postContentWithJsonBody(jsonString: loginData._postJson, urlString: loginData._urlString, csrfToken: csrfToken, completionHandler: completeLoginAction)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any)
    {
        let loginData : LoginOrSignupData = LoginOrSignupData(urlString: "rest-auth/login/", postJson: getLoginDataAsJson())
        WebUtils().runFunctionAfterGettingCsrfToken(functionData: loginData, completionHandler: self.performLoginAction)
    }
    
    @IBAction func signupButtonPressed(_ sender: Any)
    {
        performSegue(withIdentifier: "showSignupSegue", sender: self)
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any)
    {
        performSegue(withIdentifier: "forgotPasswordSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let nextViewController = segue.destination as! GenericProgramViewController
        nextViewController.shouldPressBackAndNotSegue = true
        nextViewController.viewControllerToReturnTo = self.viewControllerToReturnTo
    }
}
