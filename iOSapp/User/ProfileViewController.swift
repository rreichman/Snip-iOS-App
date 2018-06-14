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
    func onFavoriteSnipsRequested()
    func onSettingsClicked()
}

class ProfileViewController : GenericProgramViewController {
    
    
    
    @IBOutlet var avatarContainer: UIView!
    @IBOutlet var favoriteSnipsButton: UIView!
    @IBOutlet var savedSnipsButton: UIView!
    @IBOutlet var initialsLabel: UILabel!
    @IBOutlet var fullNameLabel: UILabel!
    
    var userPrfile: User?
    var delegate: ProfileViewDelegate!
    override func viewDidLoad()
    {
        bind(profile: self.userPrfile)
        addSettingsBarItem()
        setButtons()
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
    
    
    func bind(profile: User?) {
        self.userPrfile = profile
        guard let _ = fullNameLabel else { return }
        if let u = profile {
            setHidden(false)
            fullNameLabel.text = "\(u.first_name) \(u.last_name)"
            initialsLabel.text = "\(u.initials.uppercased())"
        } else {
            setHidden(true)
            fullNameLabel.text = ""
            initialsLabel.text = ""
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
}
