//
//  UserImage.swift
//  iOSapp
//
//  Created by Ran Reichman on 2/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

@IBDesignable

class UserImage: UIView {
    
    var contentView : UIView?
    
    @IBOutlet weak var leftInitial: UITextView!
    @IBOutlet weak var rightInitial: UITextView!
    
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
        
        self.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(self.frame.size.width / 2)
        
        leftInitial.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        rightInitial.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        return view
    }
}
