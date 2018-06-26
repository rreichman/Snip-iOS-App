//
//  ProfileViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/30/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//
import Foundation
import UIKit
import RealmSwift
import Nuke

protocol ProfileViewDelegate: class {
    func viewDidAppear()
    func onSavedPostsRequested()
    func onFavoriteSnipsRequested()
    func onSettingsClicked()
}

class ProfileViewController : GenericProgramViewController {
    
    
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var avatarContainer: UIView!
    @IBOutlet var favoriteSnipsButton: UIView!
    @IBOutlet var savedSnipsButton: UIView!
    @IBOutlet var initialsLabel: UILabel!
    @IBOutlet var fullNameLabel: UILabel!
    
    var userProfile: User?
    var updateToken: NotificationToken?
    var delegate: ProfileViewDelegate!
    override func viewDidLoad()
    {
        self.bindViews(user: userProfile)
        addSettingsBarItem()
        setButtons()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func addSettingsBarItem() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 44, height: 44)
        menuBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 0)
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
    
    
    func bindData(user: User?) {
        self.userProfile = user
        //self.subscribeToNotifications(user: user)
        self.bindViews(user: user)
    }
    
    /**
    
    private func subscribeToNotifications(user: User?) {
        if let u = user, let avatarImage = u.avatarImage {
            self.updateToken = avatarImage.observe({ [weak self] (changes) in
                print("Profile NotificationChangeBlock \(changes)")
                guard let vc = self else { return }
                vc.bindViews(user: vc.userProfile)
            })
        } else {
            self.unsubscribeFromNotifications()
        }
    }
    
    private func unsubscribeFromNotifications() {
        if let token = self.updateToken {
            token.invalidate()
        }
        self.updateToken = nil
    }
    **/
    
    func bindViews(user: User?) {
        //Check to make sure views have been bound
        guard let _ = fullNameLabel else { return }
        
        if let u = user {
            setHidden(false)
            fullNameLabel.text = "\(u.first_name) \(u.last_name)"
            initialsLabel.text = "\(u.initials.uppercased())"
            if let avatarURL = URL(string: u.avatarUrl) {
                Nuke.loadImage(with: avatarURL, into: self.avatarImageView)
            } else {
                self.avatarImageView.image = nil
            }
            
            /**
            if u.hasAvatarImageData() {
                avatarImageView.isHidden = false
                avatarImageView.image = UIImage(data: u.avatarImage!.data!)
            }
            **/
        } else {
            setHidden(true)
            fullNameLabel.text = ""
            initialsLabel.text = ""
            self.avatarImageView.image = nil
        }
    }
    
    func setHidden(_ hidden: Bool) {
        initialsLabel.isHidden = hidden
        savedSnipsButton.isHidden = hidden
        favoriteSnipsButton.isHidden = hidden
        avatarContainer.isHidden = hidden
    }
    override func viewDidAppear(_ animated: Bool)
    {
        //Show login on return if not logged in
        delegate.viewDidAppear()
    }
    
    func setButtons()
    {
        
        let savedSnipsClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSavedSnipsRequested))
        savedSnipsButton.isUserInteractionEnabled = true
        savedSnipsButton.addGestureRecognizer(savedSnipsClickRecognizer)
        
        let loginClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onFavoriteSnipsRequested))
        favoriteSnipsButton.isUserInteractionEnabled = true
        favoriteSnipsButton.addGestureRecognizer(loginClickRecognizer)
    }
    
    
    @objc func settingsClicked(sender: UITapGestureRecognizer)
    {
        print("settings")
        Logger().logClickedOnSettings()
        delegate.onSettingsClicked()
    }
    
    @objc func onSavedSnipsRequested() {
        Logger().logClickMyUpvotes()
        delegate.onSavedPostsRequested()
    }
    @objc func onFavoriteSnipsRequested() {
        delegate.onFavoriteSnipsRequested()
    }
    
    deinit {
        //self.unsubscribeFromNotifications()
    }
}
