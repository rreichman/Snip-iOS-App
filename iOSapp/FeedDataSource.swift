//
//  FeedDataSource.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/29/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class FeedDataSource: NSObject, UITableViewDataSource
{
    var postDataArray: [PostData] = []
    var _tableView: UITableView
    var cellsNotToTruncate : Set<Int> = Set<Int>()
    
    override init()
    {
         _tableView = UITableView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        _tableView = tableView
        
        //var current = Date().timeIntervalSince1970
        
        //handleInfiniteScroll(tableView : tableView, currentRow: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SnippetTableViewCell
        let postData = postDataArray[indexPath.row]
        
        // TODO:: return this
        //self.setUpvoteDownvoteImagesAccordingtoVote(cell : cell, postData : postData)
        
        let timeAndWriterString = self.generateTimeAndWriterString(postData: postData)
        fillPublishTimeAndWriterInfo(cell: cell, timeAndWriterAttributedString: timeAndWriterString)
        
        loadImageData(cell: cell, postData: postData)
        
        fillImageDescription(cell: cell, imageDescription: postData.imageDescriptionAfterHtmlRendering)
        
        let shouldTruncate : Bool = !self.cellsNotToTruncate.contains(indexPath.row)
        
        setCellText(tableViewCell : cell, postData : self.postDataArray[indexPath.row], shouldTruncate: shouldTruncate)
        
        setCellReferences(tableViewCell : cell, postData: self.postDataArray[indexPath.row], shouldTruncate: shouldTruncate)
        
        //setCellCommentPreview(tableViewCell: cell, postData: self.postDataArray[indexPath.row], shouldTruncate: shouldTruncate)
        
        cell.snippetView.headline.text = postData.headline
        
        //cell.snippetView.currentSnippetId = postData.id
        //cell.snippetView.headline.text = String(postData.id)
        //print(cell.snippetView.currentSnippetId)
        
        /*let postData = postDataArray[indexPath.row]
        
        print("0: \(10000 * (Date().timeIntervalSince1970 - current))")
        current = Date().timeIntervalSince1970
        let timeAndWriterString = self.generateTimeAndWriterString(postData: postData)
        fillPublishTimeAndWriterInfo(cell: cell, timeAndWriterAttributedString: timeAndWriterString)
        
        print("1: \(10000 * (Date().timeIntervalSince1970 - current))")
        current = Date().timeIntervalSince1970
        loadImageData(cell: cell, postData: postData)
        print("2: \(10000 * (Date().timeIntervalSince1970 - current))")
        current = Date().timeIntervalSince1970
        fillImageDescription(cell: cell, imageDescription: postData.imageDescriptionAfterHtmlRendering)
        print("3: \(10000 * (Date().timeIntervalSince1970 - current))")
        current = Date().timeIntervalSince1970
        
        self.makeCellClickable(tableViewCell : cell)
        
        let shouldTruncate : Bool = !self.cellsNotToTruncate.contains(indexPath.row)
        
        print("4: \(10000 * (Date().timeIntervalSince1970 - current))")
        current = Date().timeIntervalSince1970
        setCellText(tableViewCell : cell, postData : self.postDataArray[indexPath.row], shouldTruncate: shouldTruncate)
        print("5: \(10000 * (Date().timeIntervalSince1970 - current))")
        current = Date().timeIntervalSince1970
        setCellReferences(tableViewCell : cell, postData: self.postDataArray[indexPath.row], shouldTruncate: shouldTruncate)
        print("6: \(10000 * (Date().timeIntervalSince1970 - current))")
        current = Date().timeIntervalSince1970
        setCellCommentPreview(tableViewCell: cell, postData: self.postDataArray[indexPath.row], shouldTruncate: shouldTruncate)
        print("7: \(10000 * (Date().timeIntervalSince1970 - current))")
        current = Date().timeIntervalSince1970
        
        self.setUpvoteDownvoteImagesAccordingtoVote(cell : cell, postData : postData)
        self.turnActionImagesIntoButtons(cell: cell)
        
        print("8: \(10000 * (Date().timeIntervalSince1970 - current))")
        current = Date().timeIntervalSince1970
        cell.headline.text = postData.headline
        
        print("9: \(10000 * (Date().timeIntervalSince1970 - current))")
        current = Date().timeIntervalSince1970
        print("10: \(10000 * (Date().timeIntervalSince1970 - current))")*/
        
        print("returning cell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return postDataArray.count
    }
    
    func handleInfiniteScroll(tableView : UITableView, currentRow : Int)
    {
        let SPARE_ROWS_UNTIL_MORE_SCROLL = 5
        if postDataArray.count - currentRow < SPARE_ROWS_UNTIL_MORE_SCROLL
        {
            print("getting more posts. Current URL string: \(SnipRetrieverFromWeb.shared.currentUrlString)")
            Logger().logScrolledToInfiniteScroll()
            let tableViewController : SnippetsTableViewController = tableView.delegate as! SnippetsTableViewController
            SnipRetrieverFromWeb.shared.loadMorePosts(completionHandler: tableViewController.dataCollectionCompletionHandler)
        }
    }
    
    func generateTimeAndWriterString(postData: PostData) -> NSAttributedString
    {
        return NSAttributedString(string : postData.timeAndWriterString, attributes: postData.PUBLISH_TIME_AND_WRITER_ATTRIBUTES)
    }
    
    func loadImageData(cell: SnippetTableViewCell, postData: PostData)
    {
        cell.snippetView.postImage.image = nil
        if (postData.image._gotImageData)
        {
            cell.snippetView.postImageHeightConstraint.constant = postData.image._imageHeight
            cell.snippetView.postImage.image = postData.image.getImageData()
        }
    }
    
    func getSnippetComments(snippetID : Int) -> [Comment]
    {
        for i in 0...postDataArray.count-1
        {
            if (postDataArray[i].id == snippetID)
            {
                return postDataArray[i].comments
            }
        }
        
        return []
    }
    
    func setSnippetComments(snippetID : Int, newComments : [Comment])
    {
        for i in 0...postDataArray.count-1
        {
            if (postDataArray[i].id == snippetID)
            {
                let newPostData = postDataArray[i]
                newPostData.comments = newComments
                postDataArray[i] = newPostData
            }
        }
    }
    
    // Cell UI management functions
    
    func makeCellClickable(tableViewCell : SnippetTableViewCell)
    {
        let singleTapRecognizerImage : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.postImage.isUserInteractionEnabled = true
        tableViewCell.postImage.addGestureRecognizer(singleTapRecognizerImage)
        
        let singleTapRecognizerImageDescription : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.imageDescription.isUserInteractionEnabled = true
        tableViewCell.imageDescription.addGestureRecognizer(singleTapRecognizerImageDescription)
        
        let singleTapRecognizerText : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.body.isUserInteractionEnabled = true
        tableViewCell.body.addGestureRecognizer(singleTapRecognizerText)
        
        let singleTapRecognizerHeadline : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.headline.isUserInteractionEnabled = true
        tableViewCell.headline.addGestureRecognizer(singleTapRecognizerHeadline)
        
        let singleTapRecognizerPostTimeAndAuthor : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.postTimeAndWriter.isUserInteractionEnabled = true
        tableViewCell.postTimeAndWriter.addGestureRecognizer(singleTapRecognizerPostTimeAndAuthor)
        
        let singleTapRecognizerReferences : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.references.isUserInteractionEnabled = true
        tableViewCell.references.addGestureRecognizer(singleTapRecognizerReferences)
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
    
    func getRowNumberOfClickOnTableView(sender : UITapGestureRecognizer) -> Int
    {
        let clickCoordinates = sender.location(in: _tableView)
        return _tableView.indexPathForRow(at: clickCoordinates)!.row
    }
    
    func handleClickOnUpvoteDownvote(isUpButton : Bool, sender : UITapGestureRecognizer)
    {
        // TODO:: handle errors here
        
        let imageViewWithMetadata = sender.view as! UIImageViewWithMetadata
        let tableViewCell : SnippetTableViewCell = sender.view?.superview?.superview?.superview as! SnippetTableViewCell
        var otherButton : UIImageViewWithMetadata = tableViewCell.downButton
        
        if (!isUpButton)
        {
            otherButton = tableViewCell.upButton
        }
        
        let currentSnipID = postDataArray[getRowNumberOfClickOnTableView(sender: sender)].id
        Logger().logClickedLikeOrDislike(isLikeClick: isUpButton, snipID: currentSnipID, wasClickedBefore: imageViewWithMetadata.isClicked)
        
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
        let tableViewController : SnippetsTableViewController = _tableView.delegate as! SnippetsTableViewController
        tableViewController.rowCurrentlyClicked = getRowNumberOfClickOnTableView(sender: sender)
        tableViewController.commentsButtonPressed(tableViewController)
    }
    
    @objc func handleClickOnShare(sender : UITapGestureRecognizer)
    {
        print("clicked on share")
        
        let currentCell = sender.view?.superview?.superview?.superview as! SnippetTableViewCell
        let message = "Check out this snippet:\n" + currentCell.headline.text!
        
        if let link = NSURL(string: "http://snip.today")
        {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            let tableViewController : SnippetsTableViewController = _tableView.delegate as! SnippetsTableViewController
            tableViewController.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func setUpvoteDownvoteImagesAccordingtoVote(cell : SnippetTableViewCell, postData : PostData)
    {
        if (postData.isLiked)
        {
            cell.snippetView.upvoteButton.image = cell.upButton.clickedImage
        }
        else
        {
            cell.snippetView.upvoteButton.image = cell.upButton.unclickedImage
        }
        
        if (postData.isDisliked)
        {
            cell.snippetView.downvoteButton.image = cell.downButton.clickedImage
        }
        else
        {
            cell.snippetView.downvoteButton.image = cell.downButton.unclickedImage
        }
    }
    
    func turnActionImagesIntoButtons(cell : SnippetTableViewCell)
    {
        let upButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleClickOnUpvote(sender:)))
        cell.snippetView.upvoteButton.isUserInteractionEnabled = true
        cell.snippetView.upvoteButton.addGestureRecognizer(upButtonClickRecognizer)
        
        let downButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleClickOnDownvote(sender:)))
        cell.snippetView.downvoteButton.isUserInteractionEnabled = true
        cell.snippetView.downvoteButton.addGestureRecognizer(downButtonClickRecognizer)
        
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
        cell.snippetView.shareButton.isUserInteractionEnabled = true
        cell.snippetView.shareButton.addGestureRecognizer(shareButtonClickRecognizer)
    }
    
    func logClickOnText(isReadMore : Bool, sender : UITapGestureRecognizer)
    {
        let snipID = postDataArray[getRowNumberOfClickOnTableView(sender: sender)].id
        let tableViewCell : SnippetTableViewCell = sender.view?.superview?.superview as! SnippetTableViewCell
        
        if (tableViewCell.m_isTextLongEnoughToBeTruncated)
        {
            if (isReadMore)
            {
                Logger().logReadMoreEvent(snipID: snipID)
            }
            else
            {
                Logger().logReadLessEvent(snipID: snipID)
            }
        }
        else
        {
            Logger().logTapOnNonTruncableText(snipID: snipID)
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
        
        let indexPath = _tableView.indexPathForRow(at: sender.location(in: _tableView))
        let isReadMore : Bool = !cellsNotToTruncate.contains(indexPath!.row)
        
        if (isReadMore)
        {
            cellsNotToTruncate.insert(indexPath!.row)
        }
        else
        {
            cellsNotToTruncate.remove(indexPath!.row)
        }
        
        logClickOnText(isReadMore: isReadMore, sender: sender)
        
        UIView.performWithoutAnimation
            {
                _tableView.beginUpdates()
                _tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.none)
                _tableView.endUpdates()
        }
    }
}
