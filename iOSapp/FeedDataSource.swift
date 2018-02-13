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
        
        handleInfiniteScroll(tableView : tableView, currentRow: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SnippetTableViewCell
        let postData = postDataArray[indexPath.row]
        
        self.setUpvoteDownvoteImagesAccordingtoVote(cell : cell, postData : postData)
        
        let timeAndWriterString = self.generateTimeAndWriterString(postData: postData)
        fillPublishTimeAndWriterInfo(cell: cell, timeAndWriterAttributedString: timeAndWriterString)
        
        loadImageData(cell: cell, postData: postData)
        
        fillImageDescription(cell: cell, imageDescription: postData.imageDescriptionAfterHtmlRendering)
        
        self.makeCellClickable(tableViewCell : cell)
        
        let shouldTruncate : Bool = !self.cellsNotToTruncate.contains(indexPath.row)
        
        setCellText(tableViewCell : cell, postData : self.postDataArray[indexPath.row], shouldTruncate: shouldTruncate)
        
        setCellReferences(tableViewCell : cell, postData: self.postDataArray[indexPath.row], shouldTruncate: shouldTruncate)
        
        cell.snippetView.headline.text = postData.headline
        cell.snippetView.fullURL = postData.fullURL
        cell.snippetView.currentSnippetId = postData.id
        
        cell.snippetView.setNeedsLayout()
        cell.snippetView.layoutIfNeeded()
        
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
    
    /*func getSnippetData(snippetID : Int) -> PostData
    {
        
    }*/
    
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
        tableViewCell.snippetView.postImage.isUserInteractionEnabled = true
        tableViewCell.snippetView.postImage.addGestureRecognizer(singleTapRecognizerImage)
        
        let singleTapRecognizerImageDescription : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.snippetView.imageDescription.isUserInteractionEnabled = true
        tableViewCell.snippetView.imageDescription.addGestureRecognizer(singleTapRecognizerImageDescription)
        
        let singleTapRecognizerText : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.snippetView.body.isUserInteractionEnabled = true
        tableViewCell.snippetView.body.addGestureRecognizer(singleTapRecognizerText)
        
        let singleTapRecognizerHeadline : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.snippetView.headline.isUserInteractionEnabled = true
        tableViewCell.snippetView.headline.addGestureRecognizer(singleTapRecognizerHeadline)
        
        let singleTapRecognizerPostTimeAndAuthor : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.snippetView.postTimeAndWriter.isUserInteractionEnabled = true
        tableViewCell.snippetView.postTimeAndWriter.addGestureRecognizer(singleTapRecognizerPostTimeAndAuthor)
        
        let singleTapRecognizerReferences : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.snippetView.references.isUserInteractionEnabled = true
        tableViewCell.snippetView.references.addGestureRecognizer(singleTapRecognizerReferences)
    }
    
    func setUpvoteDownvoteImagesAccordingtoVote(cell : SnippetTableViewCell, postData : PostData)
    {
        if (postData.isLiked)
        {
            cell.snippetView.upvoteButton.image = cell.snippetView.upvoteButton.clickedImage
        }
        else
        {
            cell.snippetView.upvoteButton.image = cell.snippetView.upvoteButton.unclickedImage
        }
        
        if (postData.isDisliked)
        {
            cell.snippetView.downvoteButton.image = cell.snippetView.downvoteButton.clickedImage
        }
        else
        {
            cell.snippetView.downvoteButton.image = cell.snippetView.downvoteButton.unclickedImage
        }
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
        let snipID = postDataArray[getRowNumberOfClickOnTableView(sender: sender, tableView: _tableView)].id
        let tableViewCell : SnippetTableViewCell = sender.view?.superview?.superview?.superview?.superview as! SnippetTableViewCell
        
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
