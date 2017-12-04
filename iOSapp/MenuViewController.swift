//
//  MenuViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/21/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class MenuViewController : GenericProgramViewController
{
    @IBOutlet weak var termsOfServiceButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    
    @IBAction func clickedTermsOfServiceButton(_ sender: UIButton)
    {
        UIApplication.shared.open(URL(string: SystemVariables().TERMS_OF_SERVICE_URL)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func clickedPrivacyPolicyButton(_ sender: UIButton)
    {
        UIApplication.shared.open(URL(string: SystemVariables().PRIVACY_POLICY_URL)!, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Making the "Back" button black instead of blue
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
}
