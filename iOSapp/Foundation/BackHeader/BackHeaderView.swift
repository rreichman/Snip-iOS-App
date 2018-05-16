//
//  BackHeaderView.swift
//  iOSapp
//
//  Created by Ran Reichman on 4/5/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
@IBDesignable
open class BackHeaderView: UIView
{
    var contentView : UIView?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    var showNavigationBarOnBack : Bool = false
    
    var currentViewController : UIViewController = GenericProgramViewController()
    
    override open func awakeFromNib() {
        super.awakeFromNib()
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
        
        headerView.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        let backButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.backButtonClicked(sender:)))
        backButtonView.isUserInteractionEnabled = true
        backButtonView.addGestureRecognizer(backButtonClickRecognizer)
        
        setConstraintToMiddleOfScreen(constraint: titleLabelTrailingConstraint, view: titleLabel)
        
        return view
    }
    
    @objc func backButtonClicked(sender : UITapGestureRecognizer)
    {
        print("back button clicked")
        goBackToPreviousViewController(navigationController: currentViewController.navigationController!, showNavigationBar: showNavigationBarOnBack)
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }
}
