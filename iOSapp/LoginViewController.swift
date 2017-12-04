//
//  LoginViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/30/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController
{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // This isn't a generic function for all screens because of the Navigation Controller
    func segueBackToFeedAfterLogin(alertAction: UIAlertAction)
    {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func completeLoginAction(responseString: String)
    {
        if let jsonObj = try? JSONSerialization.jsonObject(with: responseString.data(using: .utf8)!, options: .allowFragments) as! [String : Any]
        {
            DispatchQueue.main.async
                {
                    if jsonObj.keys.count == 1 && jsonObj.keys.contains("key")
                    {
                        storeUserInformation(authenticationToken: jsonObj["key"] as! String)
                        
                        promptToUser(promptMessageTitle: "Login successful!", promptMessageBody: "", viewController: self, completionHandler: self.segueBackToFeedAfterLogin)
                    }
                    else
                    {
                        var messageString : String = ""
                        for key in jsonObj.keys
                        {
                            messageString.append("\n- ")
                            let arrayInJsonResponse : Any = (jsonObj[key] as! Array)[0]
                            messageString.append(arrayInJsonResponse as! String)
                        }
                        promptToUser(promptMessageTitle: "Error", promptMessageBody: messageString, viewController: self)
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
    
    func performSignupAction(handlerParams : Any, csrfToken : String)
    {
        var urlString : String = SystemVariables().URL_STRING
        urlString.append("rest-auth/login/")
        SnipRetrieverFromWeb().postContentWithJsonBody(jsonString: getLoginDataAsJson(), urlString: urlString, csrfToken: csrfToken, completionHandler: completeLoginAction)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any)
    {
        SnipRetrieverFromWeb().runFunctionAfterGettingCsrfToken(functionData: "", completionHandler: self.performSignupAction)
    }
    
    @IBAction func signupButtonPressed(_ sender: Any)
    {
        print("signup pressed")
        performSegue(withIdentifier: "showSignupSegue", sender: self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Making the "Back" button black instead of blue
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        emailTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderWidth = 0.5
        
        self.view.backgroundColor = SystemVariables().LOGIN_BACKGROUND_COLOR
        loginButton.backgroundColor = SystemVariables().LOGIN_BUTTON_COLOR
    }
}
