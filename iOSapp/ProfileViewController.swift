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
    
    @IBOutlet weak var profileTopView: ProfileView!
    
    @IBOutlet weak var savedSnipsSurroundingView: UIView!
    @IBOutlet weak var savedSnippetsTextView: UITextView!
    @IBOutlet weak var savedSnippetsSeparator: UIView!
    
    @IBOutlet weak var settingsView: UIView!
    
    let SAVED_SNIPS_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().SAVED_SNIPS_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().SAVED_SNIPS_COLOR]
    
    override func viewDidLoad()
    {
        /*let userFirstName : String = UserInformation().getUserInfo(key: UserInformation().firstNameKey)
        */
        navigationController?.navigationBar.isHidden = true
        
        removePaddingFromTextView(textView: savedSnippetsTextView)
        savedSnippetsTextView.attributedText = NSAttributedString(string: "Saved Snips", attributes: SAVED_SNIPS_ATTRIBUTES)
        
        savedSnippetsSeparator.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
        
        setButtons()
        
        let userFullName = UserInformation().getUserInfo(key: UserInformation().firstNameKey) + " " + UserInformation().getUserInfo(key: UserInformation().lastNameKey)
        profileTopView.setUI(receivedUserFullName: userFullName)
        profileTopView.backButtonView.isHidden = true
        
        if (!UserInformation().isUserLoggedIn())
        {
            performSegue(withIdentifier: "showWelcomeScreen", sender: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        print("appeared")
    }
    
    func setButtons()
    {
        let settingsClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.settingsClicked(sender:)))
        settingsView.isUserInteractionEnabled = true
        settingsView.addGestureRecognizer(settingsClickRecognizer)
        
        let savedSnipsClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.savedSnipsClicked(sender:)))
        savedSnipsSurroundingView.isUserInteractionEnabled = true
        savedSnipsSurroundingView.addGestureRecognizer(savedSnipsClickRecognizer)
    }
    
    @objc func settingsClicked(sender: UITapGestureRecognizer)
    {
        print("settings")
        Logger().logClickedOnSettings()
        
        performSegue(withIdentifier: "showSettingsSegue", sender: self)
    }
    
    @objc func savedSnipsClicked(sender: UITapGestureRecognizer)
    {
        print("clicked on saved snips")
        Logger().logClickMyUpvotes()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let snippetsViewController : SnippetsTableViewController = storyboard.instantiateViewController(withIdentifier: "Snippets") as! SnippetsTableViewController
        snippetsViewController.shouldShowProfileView = false
        snippetsViewController.snipRetrieverFromWeb.setCurrentUrlString(urlString: SystemVariables().URL_STRING + "my-upvotes/")
        snippetsViewController.shouldShowNavigationBar = false
        snippetsViewController.shouldShowBackView = true
        snippetsViewController.fillSnippetViewController()
        
        snippetsViewController.titleHeadlineString = LoginDesignUtils.shared.SAVED_SNIPS_HEADLINE_STRING
        //snippetsViewController.pageWriterIfExists = writerName.text!
        
        //self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(snippetsViewController, animated: true)
    }
    
    func logout(action: UIAlertAction)
    {
        UserInformation().logOutUser()
        promptToUser(promptMessageTitle: "Log out successful!", promptMessageBody: "", viewController: self, completionHandler: self.segueBackToContent)
    }
    
    @IBAction func logoutButton(_ sender: Any)
    {
        print("in logout")
        let alertController : UIAlertController = UIAlertController(title: "Are you sure you want to log out?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let alertActionOk : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.logout)
        let alertActionCancel : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(alertActionOk)
        alertController.addAction(alertActionCancel)
        present(alertController, animated: true, completion: nil)
    }
    
    // TODO: show user likes here
}
