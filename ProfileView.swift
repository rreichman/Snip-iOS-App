//
//  ProfileView.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

//
//  ProfileView.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

@IBDesignable

class ProfileView: UIView
{
    var contentView : UIView?
    
    @IBOutlet weak var backButtonView: UIView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var userImage: UserImage!
    @IBOutlet weak var userImageLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userNameLeadingConstraint: NSLayoutConstraint!
    
    var userFullName : String = "User Name"
    var currentViewController : SnippetsTableViewController = SnippetsTableViewController()
    
    let USERNAME_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().PROFILE_NAME_TEXT_FONT!, NSAttributedStringKey.foregroundColor : UIColor.white]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView!.frame = bounds
        
        // Make the view stretch with containing view
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView!)
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        backgroundImage.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        let backButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.backButtonClicked(sender:)))
        backButtonView.isUserInteractionEnabled = true
        backButtonView.addGestureRecognizer(backButtonClickRecognizer)
        
        setUI(receivedUserFullName: userFullName)
        
        return view
    }
    
    @objc func backButtonClicked(sender: UITapGestureRecognizer)
    {
        if (currentViewController.viewControllerToReturnTo is SnippetsTableViewController)
        {
            currentViewController.navigationController?.navigationBar.isHidden = !(currentViewController.viewControllerToReturnTo as! SnippetsTableViewController).shouldShowNavigationBar
        }
        else
        {
            currentViewController.navigationController?.navigationBar.isHidden = !currentViewController.shouldShowNavigationBar
        }
        currentViewController.segueBackToContent(alertAction: UIAlertAction())
    }
    
    func setUI(receivedUserFullName: String)
    {
        userFullName = receivedUserFullName
        userName.attributedText = NSAttributedString(string: userFullName, attributes: USERNAME_ATTRIBUTES)
        
        let usernameSize = (userFullName as NSString).size(withAttributes: USERNAME_ATTRIBUTES).width
        userImage.initials.backgroundColor = UIColor.black
        userImage.backgroundColor = UIColor.black
        
        userImage.loadInitialsIntoUserImage(writerName: userName.attributedText!, sizeOfView: 60, sizeOfFont: 20)
        
        userImageLeadingConstraint.constant = (CachedData().getScreenWidth() - userImage.frame.width) / 2
        userNameLeadingConstraint.constant = (CachedData().getScreenWidth() - usernameSize) / 2
    }
}

