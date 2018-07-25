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
    
    @IBOutlet var stackView: UIStackView!
    var firstSetting: SettingsMember!
    var secondSetting: SettingsMember!
    var thirdSetting: SettingsMember!
    var notificationSettings: SettingsMember?
    
    var delegate: SettingsViewDelegate!
    
    var settings: [SettingsMember] = []
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = "Settings".uppercased()
        
        
        viewInit()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func viewInit()
    {
        firstSetting = SettingsMember()
        firstSetting.imageView.image = #imageLiteral(resourceName: "myAccount")
        firstSetting.textView.attributedText = LoginDesignUtils.shared.PRIVACY_POLICY_STRING
        firstSetting.isUserInteractionEnabled = true
        firstSetting.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyPolicyClicked)))
        self.settings.append(firstSetting)
        addSettingsToStack(memeber: firstSetting)
        secondSetting = SettingsMember()
        secondSetting.imageView.image = #imageLiteral(resourceName: "terms")
        secondSetting.textView.attributedText = LoginDesignUtils.shared.TERMS_OF_SERVICE_STRING
        self.settings.append(secondSetting)
        addSettingsToStack(memeber: secondSetting)
        secondSetting.isUserInteractionEnabled = true
        secondSetting.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsOfServiceClicked)))
        thirdSetting = SettingsMember()
        thirdSetting.imageView.image = #imageLiteral(resourceName: "logout")
        thirdSetting.textView.attributedText = LoginDesignUtils.shared.LOGOUT_STRING
        thirdSetting.isUserInteractionEnabled = true
        thirdSetting.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logoutClicked)))
        self.settings.append(thirdSetting)
        addSettingsToStack(memeber: thirdSetting)
        if !NotificationManager.instance.haveNotificationAccess {
            let notification = SettingsMember()
            notification.imageView.image = #imageLiteral(resourceName: "notification")
            notification.textView.attributedText = LoginDesignUtils.shared.NOTIFICATION_STRING
            notification.isUserInteractionEnabled = true
            notification.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notificationsRequested)))
            self.settings.append(notification)
            self.notificationSettings = notification
            addSettingsToStack(memeber: notification)
        }
    }
    
    private func addSettingsToStack(memeber: SettingsMember) {
        memeber.heightAnchor.constraint(equalToConstant: 61).isActive = true
        self.stackView.addArrangedSubview(memeber)
        memeber.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0).isActive = true
        memeber.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0).isActive = true
    }
    
    @objc func privacyPolicyClicked()
    {
        UIApplication.shared.open(URL(string: SystemVariables().PRIVACY_POLICY_URL)!, options: [:], completionHandler: nil)
    }
    
    @objc func termsOfServiceClicked()
    {
        UIApplication.shared.open(URL(string: SystemVariables().TERMS_OF_SERVICE_URL)!, options: [:], completionHandler: nil)
    }
    
    @objc func logoutClicked()
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
    
    @objc func notificationsRequested() {
        NotificationManager.instance.showNotificationAccessRequest()
        self.notificationSettings?.isHidden = true
    }
    
    func operateLogout(action: UIAlertAction)
    {
        delegate.onLogoutRequested()
    }

    
    @objc func backButtonTapped() {
        delegate.backRequested()
    }
}
