//
//  ProfileViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/30/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class ProfileViewController : GenericProgramViewController
{
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var welcomeText: UITextView!
    
    func logout(action: UIAlertAction)
    {
        UserInformation().logOutUser()
        promptToUser(promptMessageTitle: "Log out successful!", promptMessageBody: "", viewController: self, completionHandler: self.segueBackToContent)
    }
    
    @IBAction func logoutButton(_ sender: Any)
    {
        let alertController : UIAlertController = UIAlertController(title: "Are you sure you want to log out?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let alertActionOk : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.logout)
        let alertActionCancel : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(alertActionOk)
        alertController.addAction(alertActionCancel)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let userFirstName : String = UserInformation().getUserInfo(key: UserInformation().firstNameKey)
        var welcomeTextString : String = "Hey "
        welcomeTextString.append(userFirstName)
        welcomeTextString.append("!")
        let welcomeTextContinued : String = "\n\nWelcome to your personal profile. \n\nHere we will present your personal information, including likes, notifications, and more."
        welcomeTextString.append(welcomeTextContinued)
        welcomeText.text = welcomeTextString
     
        logoutButton.layer.borderColor = UIColor.black.cgColor
        logoutButton.layer.borderWidth = 0.5
        // Making the "Back" button black instead of blue
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    // TODO:: show user likes here
}
