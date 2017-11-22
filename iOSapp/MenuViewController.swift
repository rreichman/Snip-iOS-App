//
//  MenuViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/21/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class MenuViewController : UIViewController
{
    @IBOutlet weak var termsOfServiceButton: UIButton!
    //@IBOutlet weak var termsOfServiceButton: UIButton!
    //@IBOutlet weak var privacyPolicyButton: UIButton!
    //@IBOutlet weak var termsOfServiceButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    
    @IBAction func clickedTermsOfServiceButton(_ sender: UIButton)
    {
        print("clicked terms of service")
        UIApplication.shared.open(URL(string: SystemVariables().TERMS_OF_SERVICE_URL)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func clickedPrivacyPolicyButton(_ sender: UIButton)
    {
        print("clicked privacy policy")
        UIApplication.shared.open(URL(string: SystemVariables().PRIVACY_POLICY_URL)!, options: [:], completionHandler: nil)
    }
    /*
    
    @IBAction func clickedPrivacyPolicy(_ sender: Any)
    {
        print("clicked privacy policy")
    }*/
    
    /*@IBAction func clickTermsOfService(_ sender: UIButton)
    {
        print("clicked terms")
    }*/
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
}
