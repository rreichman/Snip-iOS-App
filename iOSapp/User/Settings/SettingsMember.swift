//
//  SettingsMember.swift
//  iOSapp
//
//  Created by Ran Reichman on 4/6/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

class SettingsMember: UIView
{
    var contentView : UIView?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var separator: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        let contentView = loadViewFromNib()!
        
        // use bounds not frame or it'll be offset
        contentView.frame = bounds
        addSubview(contentView)
        let g = self.safeAreaLayoutGuide
        contentView.topAnchor.constraint(equalTo: g.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: g.leadingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: g.bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: g.trailingAnchor).isActive = true
        // Make the view stretch with containing view
        self.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        
        self.contentView = contentView
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        removePaddingFromTextView(textView: textView)
        
        separator.backgroundColor = SystemVariables().SEPARATOR_COLOR
        
        return view
    }
}
