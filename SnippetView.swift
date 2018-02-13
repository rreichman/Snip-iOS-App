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
    @IBOutlet weak var postImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageDescription: UITextView!
    @IBOutlet weak var headline: UITextView!
    
    @IBOutlet weak var postTimeAndWriter: UITextView!
    
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var references: UITextView!
    
    @IBOutlet weak var upvoteButton: UIImageViewWithMetadata!
    
    @IBOutlet weak var downvoteButton: UIImageViewWithMetadata!
    
    @IBOutlet weak var commentButton: UIImageView!
    @IBOutlet weak var commentButtonRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shareButton: UIImageView!
    
    var currentSnippetId : Int = 0
    var fullURL : String = ""
    
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
        
        headline.font = SystemVariables().HEADLINE_TEXT_FONT
        headline.textColor = SystemVariables().HEADLINE_TEXT_COLOR
        
        turnActionImagesIntoButtons()
        
        commentButtonRightConstraint.constant = CachedData().getScreenWidth() * 0.42
        
        return view
    }
    
    func turnActionImagesIntoButtons()
    {
        let upButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleClickOnUpvote(sender:)))
        upvoteButton.isUserInteractionEnabled = true
        upvoteButton.addGestureRecognizer(upButtonClickRecognizer)
        
        let downButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleClickOnDownvote(sender:)))
        downvoteButton.isUserInteractionEnabled = true
        downvoteButton.addGestureRecognizer(downButtonClickRecognizer)
        
        let commentButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(self.handleClickOnComment(sender:)))
        commentButton.isUserInteractionEnabled = true
        commentButton.addGestureRecognizer(commentButtonClickRecognizer)
        
        let shareButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(self.handleClickOnShare(sender:)))
        shareButton.isUserInteractionEnabled = true
        shareButton.addGestureRecognizer(shareButtonClickRecognizer)
    }
    
    func handleClickOnUpvoteDownvote(isUpButton : Bool, sender : UITapGestureRecognizer)
    {
        // TODO:: handle errors here
        
        let imageViewWithMetadata = sender.view as! UIImageViewWithMetadata
        var otherButton : UIImageViewWithMetadata = downvoteButton
        
        if (!isUpButton)
        {
            otherButton = upvoteButton
        }

        Logger().logClickedLikeOrDislike(isLikeClick: isUpButton, snipID: currentSnippetId, wasClickedBefore: imageViewWithMetadata.isClicked)
        
        if (imageViewWithMetadata.isClicked)
        {
            imageViewWithMetadata.isClicked = false
            imageViewWithMetadata.image = imageViewWithMetadata.unclickedImage
        }
        else
        {
            imageViewWithMetadata.isClicked = true
            imageViewWithMetadata.image = imageViewWithMetadata.clickedImage
            otherButton.image = otherButton.unclickedImage
            otherButton.isClicked = false
        }
    }
    
    @objc func handleClickOnUpvote(sender : UITapGestureRecognizer)
    {
        handleClickOnUpvoteDownvote(isUpButton: true, sender: sender)
    }
    
    @objc func handleClickOnDownvote(sender : UITapGestureRecognizer)
    {
        handleClickOnUpvoteDownvote(isUpButton: false, sender: sender)
    }
    
    @objc func handleClickOnComment(sender : UITapGestureRecognizer)
    {
        print("clicked on comment")
        Logger().logClickCommentButton()
        
        let tableView = sender.view?.superview?.superview?.superview?.superview?.superview?.superview as! UITableView
        let tableViewController : SnippetsTableViewController = tableView.delegate as! SnippetsTableViewController
        tableViewController.rowCurrentlyClicked = getRowNumberOfClickOnTableView(sender: sender, tableView: tableView)
        tableViewController.commentsButtonPressed(tableViewController)
    }
    
    func getCurrentController(sender : UITapGestureRecognizer) -> UIViewController
    {
        let tableView = sender.view?.superview?.superview?.superview?.superview?.superview?.superview as! UITableView
        return tableView.delegate as! UIViewController
    }
    
    @objc func handleClickOnShare(sender : UITapGestureRecognizer)
    {
        print("clicked on share")
        Logger().logClickShareButton()

        let message = "Check out this snippet:\n" + headline.text
        
        if let link = NSURL(string: fullURL)
        {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            let tableViewController : SnippetsTableViewController = getCurrentController(sender: sender) as! SnippetsTableViewController
            tableViewController.present(activityVC, animated: true, completion: nil)
        }
    }
}
