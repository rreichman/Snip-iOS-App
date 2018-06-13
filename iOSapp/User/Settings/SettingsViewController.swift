//
//  SettingsViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 4/5/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

let SETTINGS_MEMBER_DESCRIPTION_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().SETTINGS_DESCRIPTION_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().SETTINGS_DESCRIPTION_COLOR]

protocol SettingsViewDelegate: class {
    func onLogoutRequested()
    func backRequested()
}

class SettingsViewController : GenericProgramViewController
{
    
    @IBOutlet weak var firstSetting: SettingsMember!
    @IBOutlet weak var secondSetting: SettingsMember!
    @IBOutlet weak var thirdSetting: SettingsMember!
    
    var delegate: SettingsViewDelegate!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = "Settings".uppercased()
        
        
        designSettings()
        setButtons()
        whiteBackArrow()
    }
    
    func designSettings()
    {
        firstSetting.imageView.image = #imageLiteral(resourceName: "myAccount")
        firstSetting.textView.attributedText = LoginDesignUtils.shared.PRIVACY_POLICY_STRING
        secondSetting.imageView.image = #imageLiteral(resourceName: "terms")
        secondSetting.textView.attributedText = LoginDesignUtils.shared.TERMS_OF_SERVICE_STRING
        thirdSetting.imageView.image = #imageLiteral(resourceName: "logout")
        thirdSetting.textView.attributedText = LoginDesignUtils.shared.LOGOUT_STRING
        
    }
    
    func setButtons()
    {
        let privacyPolicyClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.privacyPolicyClicked(sender:)))
        firstSetting.isUserInteractionEnabled = true
        firstSetting.addGestureRecognizer(privacyPolicyClickRecognizer)
        
        let termsOfServiceClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.termsOfServiceClicked(sender:)))
        secondSetting.isUserInteractionEnabled = true
        secondSetting.addGestureRecognizer(termsOfServiceClickRecognizer)
        
        let logoutClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.logoutClicked(sender:)))
        thirdSetting.isUserInteractionEnabled = true
        thirdSetting.addGestureRecognizer(logoutClickRecognizer)
    }
    
    @objc func privacyPolicyClicked(sender: UITapGestureRecognizer)
    {
        UIApplication.shared.open(URL(string: SystemVariables().PRIVACY_POLICY_URL)!, options: [:], completionHandler: nil)
    }
    
    @objc func termsOfServiceClicked(sender: UITapGestureRecognizer)
    {
        UIApplication.shared.open(URL(string: SystemVariables().TERMS_OF_SERVICE_URL)!, options: [:], completionHandler: nil)
    }
    
    @objc func logoutClicked(sender: UITapGestureRecognizer)
    {
        print("in logout")
        if (SessionManager.instance.loggedIn)
        {
            
            let alertController : UIAlertController = UIAlertController(title: "Are you sure you want to log out?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let alertActionOk : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.operateLogout)
            let alertActionCancel : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(alertActionOk)
            alertController.addAction(alertActionCancel)
            present(alertController, animated: true, completion: nil)
        }
        else
        {
            promptToUser(promptMessageTitle: "You are not logged in", promptMessageBody: "So now you're still not logged in...", viewController: self)
        }
    }
    
    func operateLogout(action: UIAlertAction)
    {
        delegate.onLogoutRequested()
    }

    
    @objc func backButtonTapped() {
        delegate.backRequested()
    }
    
    private func whiteBackArrow() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 44, height: 44)
        menuBtn.imageEdgeInsets = UIEdgeInsetsMake(14, 0, 14, 26)
        menuBtn.setImage(UIImage(named:"whiteBackArrow"), for: .normal)
        menuBtn.addTarget(self, action: #selector(backButtonTapped), for: UIControlEvents.touchUpInside)
        menuBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 44)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
}
