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
    
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var references: UITextView!
    @IBOutlet weak var referencesTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var downvoteButton: UIImageViewWithMetadata!
    @IBOutlet weak var upvoteButton: UIImageViewWithMetadata!
    
    @IBOutlet weak var button: UIImageViewWithMetadata!
    @IBOutlet weak var buttonTwo: UIImageViewWithMetadata!
    
    @IBOutlet weak var writerImage: UIImageView!
    @IBOutlet weak var writerName: UILabel!
    
    @IBOutlet weak var writerPostTime: UILabel!
    
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    
    @IBOutlet weak var upvoteView: UIView!
    @IBOutlet weak var downvoteView: UIView!
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var shareView: UIView!
    
    @IBOutlet weak var cellSeparator: UIImageView!
    
    var isTextLongEnoughToBeTruncated : Bool = true
    var isTruncated : Bool = true
    var truncatedBody : NSAttributedString = NSAttributedString()
    var nonTruncatedBody : NSAttributedString = NSAttributedString()
    
    var currentSnippetId : Int = 0
    var fullURL : String = ""
    var currentViewController = UIViewController()
    
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
        
        upvoteButton.unclickedImage = #imageLiteral(resourceName: "upvote")
        upvoteButton.clickedImage = #imageLiteral(resourceName: "upvoteGreen")
        downvoteButton.unclickedImage = #imageLiteral(resourceName: "downvote")
        downvoteButton.clickedImage = #imageLiteral(resourceName: "downvoteRed")
        
        postImage.image = #imageLiteral(resourceName: "genericImage")
        postImage.layer.shouldRasterize = true
        postImage.layer.cornerRadius = CGFloat(10.0)
        postImage.clipsToBounds = true
        
        cellSeparator.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
        
        writerImage.layer.cornerRadius = CGFloat(writerImage.frame.size.width / 2)
        writerImage.clipsToBounds = true
        
        headline.font = SystemVariables().HEADLINE_TEXT_FONT
        headline.textColor = SystemVariables().HEADLINE_TEXT_COLOR
        
        turnActionImagesIntoButtons()
        
        return view
    }
    
    func turnActionImagesIntoButtons()
    {
        let upButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleClickOnUpvote(sender:)))
        upvoteView.isUserInteractionEnabled = true
        upvoteView.addGestureRecognizer(upButtonClickRecognizer)
        
        let downButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleClickOnDownvote(sender:)))
        downvoteView.isUserInteractionEnabled = true
        downvoteView.addGestureRecognizer(downButtonClickRecognizer)
        
        let commentButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(self.handleClickOnComment(sender:)))
        commentView.isUserInteractionEnabled = true
        commentView.addGestureRecognizer(commentButtonClickRecognizer)
        
        let shareButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(self.handleClickOnShare(sender:)))
        shareView.isUserInteractionEnabled = true
        shareView.addGestureRecognizer(shareButtonClickRecognizer)
    }
    
    func handleClickOnUpvoteDownvote(isUpButton : Bool, sender : UITapGestureRecognizer)
    {
        // TODO:: handle errors here
        
        let imageViewWithMetadata : UIImageViewWithMetadata = sender.view!.subviews[0] as! UIImageViewWithMetadata
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
    
    func makeSnippetClickable(snippetView : SnippetView)
    {
        let singleTapRecognizerImage : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        snippetView.postImage.isUserInteractionEnabled = true
        snippetView.postImage.addGestureRecognizer(singleTapRecognizerImage)
        
        let singleTapRecognizerImageDescription : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        snippetView.imageDescription.isUserInteractionEnabled = true
        snippetView.imageDescription.addGestureRecognizer(singleTapRecognizerImageDescription)
        
        let singleTapRecognizerText : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        snippetView.body.isUserInteractionEnabled = true
        snippetView.body.addGestureRecognizer(singleTapRecognizerText)
        
        let singleTapRecognizerHeadline : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        snippetView.headline.isUserInteractionEnabled = true
        snippetView.headline.addGestureRecognizer(singleTapRecognizerHeadline)
        
        //let singleTapRecognizerPostTimeAndAuthor : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        //snippetView.postTimeAndWriter.isUserInteractionEnabled = true
        //snippetView.postTimeAndWriter.addGestureRecognizer(singleTapRecognizerPostTimeAndAuthor)
        
        let singleTapRecognizerReferences : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        snippetView.references.isUserInteractionEnabled = true
        snippetView.references.addGestureRecognizer(singleTapRecognizerReferences)
    }
    
    // TODO:: do this for all text views
    // Returns if the operation was handled
    func handleClickOnTextView(sender: UITapGestureRecognizer) -> Bool
    {
        let textView : UITextView = sender.view as! UITextView
        let layoutManager : NSLayoutManager = textView.layoutManager
        var location : CGPoint = sender.location(in: textView)
        location.x -= textView.textContainerInset.left;
        location.y -= textView.textContainerInset.top;
        let characterIndex : Int = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        let attributes : [NSAttributedStringKey : Any] = textView.attributedText.attributes(at: characterIndex, longestEffectiveRange: nil, in: NSRange(location: characterIndex, length: characterIndex + 1))
        for attribute in attributes
        {
            if attribute.key._rawValue == "NSLink"
            {
                // In the references these are just regular strings and not NSURLS. Perhaps change this in the future
                var linkAddress = attribute.value
                if attribute.value is NSURL
                {
                    linkAddress = (attribute.value as! NSURL).absoluteString!
                }
                
                UIApplication.shared.open(URL(string: linkAddress as! String)!, options: [:], completionHandler: nil)
                return true
            }
        }
        return false
    }
    
    func logClickOnText(isReadMore : Bool, sender : UITapGestureRecognizer)
    {
        if (isTextLongEnoughToBeTruncated)
        {
            if (isReadMore)
            {
                Logger().logReadMoreEvent(snipID: currentSnippetId)
            }
            else
            {
                Logger().logReadLessEvent(snipID: currentSnippetId)
            }
        }
        else
        {
            Logger().logTapOnNonTruncableText(snipID: currentSnippetId)
        }
    }
    
    @objc func textLabelPressed(sender: UITapGestureRecognizer)
    {
        if sender.view is UITextView
        {
            if (handleClickOnTextView(sender: sender))
            {
                return
            }
        }
        
        if (currentViewController is SnippetsTableViewController)
        {
            let viewController : SnippetsTableViewController = (currentViewController as! SnippetsTableViewController)
            let tableView : UITableView = viewController.tableView
            
            let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView))
            let isReadMore : Bool = !(viewController.tableView.dataSource as! FeedDataSource).cellsNotToTruncate.contains(indexPath!.row)
            
            if (isReadMore)
            {
                (viewController.tableView.dataSource as! FeedDataSource).cellsNotToTruncate.insert(indexPath!.row)
            }
            else
            {
                (viewController.tableView.dataSource as! FeedDataSource).cellsNotToTruncate.remove(indexPath!.row)
            }
            
            logClickOnText(isReadMore: isReadMore, sender: sender)
            
            UIView.performWithoutAnimation
            {
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.none)
                tableView.endUpdates()
            }
        }
        if (currentViewController is CommentsTableViewController)
        {
            if (isTruncated)
            {
                body.attributedText = nonTruncatedBody
                isTruncated = false
            }
            else
            {
                body.attributedText = truncatedBody
                isTruncated = true
            }
            
            (currentViewController as! CommentsTableViewController).loadSnippetView(shouldTruncate: !isTruncated)
        }
    }
    
    func setUpvoteDownvoteImagesAccordingtoVote(snippetView: SnippetView, postData : PostData)
    {
        if (postData.isLiked)
        {
            snippetView.upvoteButton.image = snippetView.upvoteButton.clickedImage
        }
        else
        {
            snippetView.upvoteButton.image = snippetView.upvoteButton.unclickedImage
        }
        
        if (postData.isDisliked)
        {
            snippetView.downvoteButton.image = snippetView.downvoteButton.clickedImage
        }
        else
        {
            snippetView.downvoteButton.image = snippetView.downvoteButton.unclickedImage
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
        
        if (currentViewController is SnippetsTableViewController)
        {
            let tableView = sender.view?.superview?.superview?.superview?.superview?.superview?.superview as! UITableView
            (currentViewController as! SnippetsTableViewController).rowCurrentlyClicked = getRowNumberOfClickOnTableView(sender: sender, tableView: tableView)
            (currentViewController as! SnippetsTableViewController).commentsButtonPressed(currentViewController)
        }
        if (currentViewController is CommentsTableViewController)
        {
            (currentViewController as! CommentsTableViewController).writeCommentBox.becomeFirstResponder()
        }
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
            
            currentViewController.present(activityVC, animated: true, completion: nil)
            //currentViewController.dismiss(animated: true, completion: nullFunc)
        }
    }
    
    func nullFunc() -> Void
    {
        
    }
}
