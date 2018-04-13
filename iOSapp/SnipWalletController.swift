//
//  SnipWalletController.swift
//  iOSapp
//
//  Created by Ran Reichman on 4/6/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

class SnipWalletController : UIViewController
{
    @IBOutlet weak var backHeaderView: BackHeaderView!
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let HEADLINE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().LOGIN_SIGNUP_BUTTON_FONT!, NSAttributedStringKey.foregroundColor : UIColor.white]
        
        backHeaderView.titleLabel.attributedText = NSAttributedString(string: "SNIP Wallet", attributes: HEADLINE_ATTRIBUTES)
        backHeaderView.backButtonView.isHidden = true
        
        backgroundView.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        //backHeaderView.titleTopConstraint.constant = 32
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
