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
    
    @IBOutlet weak var menuButton: UIView!
    
    @IBOutlet weak var userImage: UserImage!
    
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
    
    @IBOutlet weak var writerView: UIView!
    
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
    var writerUsername : String = ""
    
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
        
        //postImage.layer.shouldRasterize = true
        postImage.layer.cornerRadius = CGFloat(10.0)
        postImage.clipsToBounds = true
        
        cellSeparator.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
        
        imageDescription.tintColor = UIColor.gray
        
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
        
        let menuButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(self.handleClickOnSnippetMenu(sender:)))
        menuButton.isUserInteractionEnabled = true
        menuButton.addGestureRecognizer(menuButtonClickRecognizer)
        
        let authorViewClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(self.handleClickOnAuthorView(sender:)))
        writerView.isUserInteractionEnabled = true
        writerView.addGestureRecognizer(authorViewClickRecognizer)
    }
    
    func handleClickOnUpvoteDownvote(isUpButton : Bool, sender : UITapGestureRecognizer)
    {
        // TODO: handle errors here
        var currentButton : UIImageViewWithMetadata = upvoteButton
        var otherButton : UIImageViewWithMetadata = downvoteButton
        
        if (!isUpButton)
        {
            currentButton = downvoteButton
            otherButton = upvoteButton
        }

        Logger().logClickedLikeOrDislike(isLikeClick: isUpButton, snipID: currentSnippetId, wasClickedBefore: currentButton.isClicked)
        
        if (currentButton.isClicked)
        {
            currentButton.isClicked = false
            currentButton.image = currentButton.unclickedImage
        }
        else
        {
            currentButton.isClicked = true
            currentButton.image = currentButton.clickedImage
            otherButton.image = otherButton.unclickedImage
            otherButton.isClicked = false
        }
        
        getSnippetsTableViewController().updatePostDataAfterClick(snippetID: currentSnippetId, upvoteButton: upvoteButton, downvoteButton: downvoteButton)
    }
    
    func getSnippetsTableViewController() -> SnippetsTableViewController
    {
        if (currentViewController is SnippetsTableViewController)
        {
            return currentViewController as! SnippetsTableViewController
        }
        if (currentViewController is CommentsTableViewController)
        {
            return (currentViewController as! CommentsTableViewController).snippetsViewController
        }
        
        return SnippetsTableViewController()
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
        
        let singleTapRecognizerReferences : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        snippetView.references.isUserInteractionEnabled = true
        snippetView.references.addGestureRecognizer(singleTapRecognizerReferences)
    }
    
    // TODO: do this for all text views
    // Returns if the operation was handled
    func handleClickOnTextView(sender: UITapGestureRecognizer) -> Bool
    {
        let textView : UITextView = sender.view as! UITextView
        let layoutManager : NSLayoutManager = textView.layoutManager
        var location : CGPoint = sender.location(in: textView)
        location.x -= textView.textContainerInset.left;
        location.y -= textView.textContainerInset.top;
        let characterIndex : Int = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        if (textView.attributedText.length > 0)
        {
            let attributes : [NSAttributedStringKey : Any] = textView.attributedText.attributes(at: characterIndex, longestEffectiveRange: nil, in: NSRange(location: characterIndex, length: characterIndex + 1))
            for attribute in attributes
            {
                if attribute.key.rawValue == "NSLink"
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
            let isReadMore : Bool = !viewController.cellsNotToTruncate.contains(indexPath!.row)
            
            if (isReadMore)
            {
                viewController.cellsNotToTruncate.insert(indexPath!.row)
            }
            else
            {
                viewController.cellsNotToTruncate.remove(indexPath!.row)
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
    
    func operateHandleClickOnComment(tableView : UITableView, rowCurrentlyClicked : Int)
    {
        DispatchQueue.global(qos: .default).async
        {
            Logger().logClickCommentButton()
        }
        
        if (currentViewController is SnippetsTableViewController)
        {
            (currentViewController as! SnippetsTableViewController).rowCurrentlyClicked = rowCurrentlyClicked
            (currentViewController as! SnippetsTableViewController).commentsButtonPressed(currentViewController)
        }
        if (currentViewController is CommentsTableViewController)
        {
            (currentViewController as! CommentsTableViewController).writeCommentBox.becomeFirstResponder()
        }
    }
    
    @objc func handleClickOnComment(sender : UITapGestureRecognizer)
    {
        if (currentViewController is SnippetsTableViewController)
        {
            
            let tableView = sender.view?.superview?.superview?.superview?.superview?.superview?.superview as! UITableView
            operateHandleClickOnComment(tableView: tableView, rowCurrentlyClicked: getRowNumberOfClickOnTableView(sender: sender, tableView: tableView))
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
            activityVC.popoverPresentationController?.sourceView = shareView
            
            currentViewController.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @objc func handleClickOnAuthorView(sender : UITapGestureRecognizer)
    {
        print("clicked on author view")
        Logger().logClickAuthorView()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let snippetsViewController : SnippetsTableViewController = storyboard.instantiateViewController(withIdentifier: "Snippets") as! SnippetsTableViewController
        snippetsViewController.shouldHaveBackButton = true
        snippetsViewController.snipRetrieverFromWeb.setCurrentUrlString(urlString: SystemVariables().URL_STRING + "?writer=" + writerUsername)
        snippetsViewController.shouldShowBackView = false
        snippetsViewController.shouldShowNavigationBar = false
        snippetsViewController.viewControllerToReturnTo = currentViewController
        snippetsViewController.fillSnippetViewController()
        snippetsViewController.pageWriterIfExists = writerName.text!
        
        currentViewController.navigationController?.navigationBar.isHidden = true
        
        currentViewController.navigationController?.pushViewController(snippetsViewController, animated: true)
    }
    
    @objc func handleClickOnSnippetMenu(sender: UITapGestureRecognizer)
    {
        print("clicked on snippet menu")
        Logger().logClickSnippetMenuButton()
        
        handleSnippetMenuButtonClicked(snippetID : currentSnippetId, viewController: currentViewController)
    }
}
