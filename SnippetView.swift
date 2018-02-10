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
    
    @IBOutlet weak var commentPreviewView: UIView!
    
    @IBOutlet weak var singleCommentPreview: UITextView!
    @IBOutlet weak var moreCommentsPreview: UITextView!
    
    @IBOutlet weak var upvoteButton: UIImageViewWithMetadata!
    
    @IBOutlet weak var downvoteButton: UIImageViewWithMetadata!
    
    @IBOutlet weak var commentButton: UIImageView!
    
    @IBOutlet weak var shareButton: UIImageView!
    
    var currentSnippetId : Int = 0
    
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
        
        //let commentButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:
        //    #selector(self.handleClickOnComment(sender:)))
        //cell.newCommentButton.isUserInteractionEnabled = true
        //cell.newCommentButton.addGestureRecognizer(commentButtonClickRecognizer)
        
        //let additionalCommentButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:
        //    #selector(self.handleClickOnComment(sender:)))
        //cell.commentPreviewView.isUserInteractionEnabled = true
        //cell.commentPreviewView.addGestureRecognizer(additionalCommentButtonClickRecognizer)
        
        let shareButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(self.handleClickOnShare(sender:)))
        shareButton.isUserInteractionEnabled = true
        shareButton.addGestureRecognizer(shareButtonClickRecognizer)
    }
    
    func handleClickOnUpvoteDownvote(isUpButton : Bool, sender : UITapGestureRecognizer)
    {
        // TODO:: handle errors here
        
        let imageViewWithMetadata = sender.view as! UIImageViewWithMetadata
        //let tableViewCell : SnippetTableViewCell = sender.view?.superview?.superview?.superview as! SnippetTableViewCell
        //var otherButton : UIImageViewWithMetadata = tableViewCell.downButton
        var otherButton : UIImageViewWithMetadata = downvoteButton
        
        if (!isUpButton)
        {
            otherButton = upvoteButton
        }
        
        //let currentSnipID = postDataArray[getRowNumberOfClickOnTableView(sender: sender)].id
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
        if (sender.view is UIImageView)
        {
            Logger().logClickCommentButton()
        }
        else
        {
            Logger().logClickCommentPreview()
        }
        //let tableViewController : SnippetsTableViewController = _tableView.delegate as! SnippetsTableViewController
        //tableViewController.rowCurrentlyClicked = getRowNumberOfClickOnTableView(sender: sender)
        //tableViewController.commentsButtonPressed(tableViewController)
    }
    
    @objc func handleClickOnShare(sender : UITapGestureRecognizer)
    {
        print("clicked on share")
        
        /*let currentCell = sender.view?.superview?.superview?.superview as! SnippetTableViewCell
        let message = "Check out this snippet:\n" + currentCell.headline.text!
        
        if let link = NSURL(string: "http://snip.today")
        {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            let tableViewController : SnippetsTableViewController = _tableView.delegate as! SnippetsTableViewController
            tableViewController.present(activityVC, animated: true, completion: nil)
        }*/
    }
}
