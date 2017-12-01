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
    
    @IBAction func loginButtonPressed(_ sender: Any)
    {
        print("login pressed")
    }
    
    @IBAction func signupButtonPressed(_ sender: Any)
    {
        print("signup pressed")
        performSegue(withIdentifier: "showSignupSegue", sender: self)
    }
    
    // TODO:: make password invisible
    
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
