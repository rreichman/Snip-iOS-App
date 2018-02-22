//
//  UserImage.swift
//  iOSapp
//
//  Created by Ran Reichman on 2/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

@IBDesignable

class UserImage: UIView
{
    var contentView : UIView?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        if self.subviews.count == 0
        {
            contentView = loadViewFromNib()
            
            // use bounds not frame or it'll be offset
            contentView!.frame = bounds
            
            // Make the view stretch with containing view
            contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
            
            // Adding custom subview on top of our view (over any custom drawing > see note below)
            addSubview(contentView!)
        }
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        //imageView.image = #imageLiteral(resourceName: "blue")
        
        return view
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
