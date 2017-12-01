//
//  SignupViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/30/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class SignupViewController : UIViewController
{
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var termsAndConditionsBox: UITextView!
    
    @IBAction func pressedRegisterButton(_ sender: Any)
    {
        // TODO:: implement
    }
    
    // TODO:: make password invisible
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Making the "Back" button black instead of blue
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        self.view.backgroundColor = SystemVariables().LOGIN_BACKGROUND_COLOR
        termsAndConditionsBox.backgroundColor = SystemVariables().LOGIN_BACKGROUND_COLOR
        registerButton.backgroundColor = SystemVariables().LOGIN_BUTTON_COLOR
    
        let termsStringPartOne : String = "By registering you confirm that you accept the "
        let termsStringPartTwo : String = "Terms and Conditions"
        let fullText : String = termsStringPartOne + termsStringPartTwo

        let termsAttributedString : NSMutableAttributedString = NSMutableAttributedString(string : fullText)
        
        
        let linkAttributes : [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.link: "https://media.snip.today/Snip+-+Terms+of+Service.pdf",
            NSAttributedStringKey.foregroundColor: UIColor.blue
            ]
        
        termsAttributedString.addAttributes(linkAttributes, range: NSMakeRange(termsStringPartOne.count, termsStringPartTwo.count))
        termsAttributedString.addAttribute(NSAttributedStringKey.font, value: SystemVariables().TERMS_AND_CONDITIONS_FONT, range: NSMakeRange(0, fullText.count))
        termsAndConditionsBox.attributedText = termsAttributedString
    }
}
