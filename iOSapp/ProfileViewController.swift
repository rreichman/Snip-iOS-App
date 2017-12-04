//
//  ProfileViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/30/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class ProfileViewController : UIViewController
{
    @IBOutlet weak var logoutButton: UIButton!
    
    func segueBackToFeedAfterLogoff(alertAction: UIAlertAction)
    {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func logoutButton(_ sender: Any)
    {
        UserInformation().logOutUser()
        promptToUser(promptMessageTitle: "Log out successful!", promptMessageBody: "", viewController: self, completionHandler: self.segueBackToFeedAfterLogoff)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
     
        logoutButton.layer.borderColor = UIColor.black.cgColor
        logoutButton.layer.borderWidth = 0.5
        // Making the "Back" button black instead of blue
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    // TODO:: show user likes here
}
