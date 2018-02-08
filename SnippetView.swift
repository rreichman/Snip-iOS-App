//
//  SnippetView.swift
//  iOSapp
//
//  Created by Ran Reichman on 2/7/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

@IBDesignable

class SnippetView: UIView {
    
    var contentView : UIView?
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var imageDescription: UITextView!
    @IBOutlet weak var headline: UITextView!
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var references: UITextView!
    
    @IBOutlet weak var commentPreviewView: UIView!
    
    @IBOutlet weak var upvoteButton: UIImageViewWithMetadata!
    
    @IBOutlet weak var downvoteButton: UIImageViewWithMetadata!
    
    @IBOutlet weak var commentButton: UIImageView!
    
    @IBOutlet weak var shareButton: UIImageView!
    
    
    
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
        
        postImage.image = #imageLiteral(resourceName: "genericImage")
        
        return view
    }
    
}
