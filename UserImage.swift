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
    
    @IBOutlet weak var initials: UITextView!
    @IBOutlet weak var initialsLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var initialsTopConstraint: NSLayoutConstraint!
    
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
        initials.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(self.frame.size.width / 2)
        
        removePaddingFromTextView(textView: initials)
        
        return view
    }
    
    func loadInitialsIntoUserImage(writerName : NSAttributedString, sizeOfView : CGFloat, sizeOfFont: CGFloat)
    {
        var writerInitials = getWriterInitials(writerString: writerName)
        
        var str : String = ""
        str.append(writerInitials[0])
        str.append(writerInitials[1])
        
        let INITIALS_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.latoBold(size: sizeOfFont), NSAttributedStringKey.foregroundColor : UIColor.white]
        
        initials.attributedText = NSAttributedString(string: str, attributes: INITIALS_ATTRIBUTES)
        
        let size = (str as NSString).size(withAttributes: INITIALS_ATTRIBUTES)
        
        initialsLeftConstraint.constant = (sizeOfView - size.width)/2
        initialsTopConstraint.constant = (sizeOfView - size.height)/2
    }
    
    func getWriterInitials(writerString : NSAttributedString) -> [Character]
    {
        let fullNameArray : [String] = writerString.string.split{$0 == " "}.map(String.init)
        
        var firstName : String = "Snip"
        var lastName : String = "Guest"
        
        if (fullNameArray.count > 0)
        {
            firstName = fullNameArray[0].uppercased()
            lastName = fullNameArray[fullNameArray.count - 1].uppercased()
        }
        
        return [getCharInString(str: firstName, position: 0), getCharInString(str: lastName, position: 0)]
    }
}
