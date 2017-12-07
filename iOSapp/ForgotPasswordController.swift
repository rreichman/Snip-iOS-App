//
//  ForgotPasswordController.swift
//  iOSapp
//
//  Created by Ran Reichman on 12/5/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class ForgotPasswordController : GenericProgramViewController
{
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var forgotPasswordText: UITextView!
    
    func backToSignup(alertAction: UIAlertAction)
    {
        navigationController?.popViewController(animated: true)
    }
    
    func handleResponseString(responseString: String)
    {
        print(responseString)
        
        if let jsonObj = try? JSONSerialization.jsonObject(with: responseString.data(using: .utf8)!, options: .allowFragments) as! [String : Any]
        {
            DispatchQueue.main.async
            {
                if jsonObj.keys.contains("detail")
                {
                    promptToUser(promptMessageTitle: "Password reset e-mail has been sent.", promptMessageBody: "Check your inbox to get the new password", viewController: self, completionHandler: self.backToSignup)
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
            // TODO:: What happens here?
        }
    }
    
    func postResetPassword(handlerParams: Any, csrfToken : String)
    {
        var postResetUrlString : String = SystemVariables().URL_STRING
        postResetUrlString.append("rest-auth/password/reset/")
        
        let emailString : String = handlerParams as! String
        
        WebUtils().postContentWithJsonBody(jsonString : ["email" : emailString], urlString : postResetUrlString, csrfToken : csrfToken, completionHandler : handleResponseString)
    }
    
    @IBAction func resetPasswordPressed(_ sender: Any)
    {
        print("reset password pressed")
        //runFunctionAfterGettingCsrfToken(functionData : Any, completionHandler: @escaping (_ handlerParams : Any, _ csrfToken : String) -> ())
        WebUtils().runFunctionAfterGettingCsrfToken(functionData: emailTextField.text, completionHandler: postResetPassword)
        
        //12
        //WebUtils().postContentWithJsonBody(jsonString : Dictionary<String,String>, urlString : String, csrfToken : String, completionHandler : @escaping (_ responseString : String) -> ())
        //WebUtils().postContentWithJsonBody(jsonString: resetPasswordJson, urlString: resetPasswordUrlString, csrfToken: )
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = SystemVariables().LOGIN_BACKGROUND_COLOR
        forgotPasswordText.backgroundColor = SystemVariables().LOGIN_BACKGROUND_COLOR
        resetPasswordButton.backgroundColor = SystemVariables().LOGIN_BUTTON_COLOR
        
        emailTextField.layer.borderWidth = 0.5
    }
}
