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
    
    @IBOutlet weak var logInSurroundingView: UIView!
    @IBOutlet weak var logInTextView: UITextView!
    @IBOutlet weak var logInSeparatorView: UIView!
    
    @IBOutlet weak var statusBarView: UIView!
    
    @IBOutlet weak var settingsView: UIView!
    
    let SAVED_SNIPS_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().SAVED_SNIPS_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().SAVED_SNIPS_COLOR]
    
    var timeOfLastWelcomScreen : TimeInterval = 0
    var shouldShowWelcomeScreen : Bool = true
    
    override func viewDidLoad()
    {
        /*let userFirstName : String = UserInformation().getUserInfo(key: UserInformation().firstNameKey)
        */
        navigationController?.navigationBar.isHidden = true
        
        removePaddingFromTextView(textView: savedSnippetsTextView)
        removePaddingFromTextView(textView: logInTextView)
        
        savedSnippetsTextView.attributedText = NSAttributedString(string: "Saved Snips", attributes: SAVED_SNIPS_ATTRIBUTES)
        logInTextView.attributedText = NSAttributedString(string: "Log In", attributes: SAVED_SNIPS_ATTRIBUTES)
        
        savedSnippetsSeparator.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
        logInSeparatorView.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
        
        setButtons()
        setUsername()
        
        statusBarView.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        profileTopView.backButtonView.isHidden = true
        
        if (UserInformation().isUserLoggedIn())
        {
            logInSurroundingView.isHidden = true
            shouldShowWelcomeScreen = false
        }
        else
        {
            moveToWelcomeScreen()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        setUsername()
        
        let currentTime : TimeInterval = Date().timeIntervalSince1970
        let ONE_HOUR_IN_SECONDS : TimeInterval = 60 * 60
        
        if (UserInformation().isUserLoggedIn())
        {
            logInSurroundingView.isHidden = true
        }
        else
        {
            logInSurroundingView.isHidden = false
            
            if (shouldShowWelcomeScreen && currentTime - timeOfLastWelcomScreen > ONE_HOUR_IN_SECONDS)
            {
                moveToWelcomeScreen()
            }
        }
    }
    
    func setButtons()
    {
        let settingsClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.settingsClicked(sender:)))
        settingsView.isUserInteractionEnabled = true
        settingsView.addGestureRecognizer(settingsClickRecognizer)
        
        let savedSnipsClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.savedSnipsClicked(sender:)))
        savedSnipsSurroundingView.isUserInteractionEnabled = true
        savedSnipsSurroundingView.addGestureRecognizer(savedSnipsClickRecognizer)
        
        let loginClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.logInClicked(sender:)))
        logInSurroundingView.isUserInteractionEnabled = true
        logInSurroundingView.addGestureRecognizer(loginClickRecognizer)
    }
    
    func setUsername()
    {
        let userFullName = UserInformation().getUserInfo(key: UserInformation().firstNameKey) + " " + UserInformation().getUserInfo(key: UserInformation().lastNameKey)
        profileTopView.setUI(receivedUserFullName: userFullName)
    }
    
    func moveToWelcomeScreen()
    {
        timeOfLastWelcomScreen = Date().timeIntervalSince1970
        
        performSegue(withIdentifier: "showWelcomeScreen", sender: self)
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
        let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedNavigationController") as! UINavigationController
        navigationController.view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        navigationController.navigationBar.tintColor = UIColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1.0)
        //self.present(navigationController, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1.0)
        let coord = GeneralFeedCoordinator(nav: self.navigationController!, mode: .savedSnips)
        coord.tempHack = true
        coord.start()
        
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let snippetsViewController : SnippetsTableViewController = storyboard.instantiateViewController(withIdentifier: "Snippets") as! SnippetsTableViewController
        snippetsViewController.shouldShowProfileView = false
        snippetsViewController.snipRetrieverFromWeb.setFullUrlString(urlString: SystemVariables().URL_STRING + "my-upvotes/", query: "")
        snippetsViewController.viewControllerToReturnTo = self
        snippetsViewController.shouldShowNavigationBar = false
        snippetsViewController.shouldShowBackView = true
        snippetsViewController.shouldHaveBackButton = true
        snippetsViewController.fillSnippetViewController()
        
        snippetsViewController.titleHeadlineString = LoginDesignUtils.shared.SAVED_SNIPS_HEADLINE_STRING
        //snippetsViewController.pageWriterIfExists = writerName.text!
        
        //self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(snippetsViewController, animated: true)
        */
    }
    
    @objc func logInClicked(sender: UITapGestureRecognizer)
    {
        print("clicked on log in")
        Logger().logClickProfileLoginButton()
        
        moveToWelcomeScreen()
    }
    
    func logout(action: UIAlertAction)
    {
        UserInformation().logOutUser()
        SessionManager.instance.oldAuthProxyLogout()
        promptToUserWithAutoDismiss(promptMessageTitle: "Log out successful!", promptMessageBody: "", viewController: self, lengthInSeconds: 1, completionHandler: self.segueBackToContent)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("profile preparing")
        let nextViewController = segue.destination as! GenericProgramViewController
        nextViewController.viewControllerToReturnTo = self
        print("profile done preparing")
    }
    
    // TODO: show user likes here
}
