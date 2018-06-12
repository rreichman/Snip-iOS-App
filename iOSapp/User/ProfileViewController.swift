//
//  ProfileViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/30/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//
import Foundation
import UIKit

protocol ProfileViewDelegate: class {
    func viewDidAppear()
    func onSavedPostsRequested()
    func onMyPostsRequested()
    func onSettingsClicked()
}

class ProfileViewController : GenericProgramViewController {
    
    @IBOutlet weak var savedSnipsSurroundingView: UIView!
    @IBOutlet weak var savedSnippetsSeparator: UIView!
    
    @IBOutlet weak var logInSurroundingView: UIView!
    @IBOutlet weak var logInSeparatorView: UIView!
    
    @IBOutlet var initialsLabel: UILabel!
    @IBOutlet var fullNameLabel: UILabel!
    
    @IBOutlet weak var settingsView: UIView!
    var userPrfile: User?
    var delegate: ProfileViewDelegate!
    override func viewDidLoad()
    {
        bind(profile: self.userPrfile)
        addSettingsBarItem()
    }
    
    func addSettingsBarItem() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 44, height: 44)
        menuBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 19, 9, 0)
        menuBtn.setImage(UIImage(named:"whiteSettingsCog"), for: .normal)
        menuBtn.addTarget(self, action: #selector(self.settingsClicked(sender:)), for: .touchUpInside)
        menuBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 44)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
    
    
    func bind(profile: User?) {
        self.userPrfile = profile
        guard let _ = fullNameLabel else { return }
        if let u = profile {
            setHidden(false)
            fullNameLabel.text = "\(u.first_name) \(u.last_name)"
            initialsLabel.text = "\(u.initials.uppercased())"
        } else {
            setHidden(true)
        }
    }
    
    func setHidden(_ hidden: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool)
    {
        //Show login on return if not logged in
        delegate.viewDidAppear()
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
    
    
    @objc func settingsClicked(sender: UITapGestureRecognizer)
    {
        print("settings")
        Logger().logClickedOnSettings()
        delegate.onSettingsClicked()
        //performSegue(withIdentifier: "showSettingsSegue", sender: self)
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
        
        //moveToWelcomeScreen()
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
