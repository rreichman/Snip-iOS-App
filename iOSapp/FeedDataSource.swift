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
        
        cell.m_isTextLongEnoughToBeTruncated = self.postDataArray[indexPath.row].m_isTextLongEnoughToBeTruncated
        let shouldTruncate : Bool = !self.cellsNotToTruncate.contains(indexPath.row)
        
        loadDataIntoSnippet(snippetView: cell.snippetView, shouldTruncate: shouldTruncate, postData: postData)
        
        return cell
    }
    
    func loadDataIntoSnippet(snippetView: SnippetView, shouldTruncate: Bool, postData: PostData)
    {
        self.setUpvoteDownvoteImagesAccordingtoVote(snippetView: snippetView, postData : postData)
        
        let timeAndWriterString = self.generateTimeAndWriterString(postData: postData)
        fillPublishTimeAndWriterInfo(snippetView: snippetView, timeAndWriterAttributedString: timeAndWriterString)
        
        loadImageData(snippetView: snippetView, postData: postData)
        
        fillImageDescription(snippetView: snippetView, imageDescription: postData.imageDescriptionAfterHtmlRendering)
        
        self.makeSnippetClickable(snippetView: snippetView)
        
        setSnippetText(snippetView: snippetView, postData : postData, shouldTruncate: shouldTruncate)
        
        setSnippetReferences(snippetView : snippetView, postData: postData, shouldTruncate: shouldTruncate, isTextLongEnoughToBeTruncated:
            postData.m_isTextLongEnoughToBeTruncated)
        
        snippetView.headline.text = postData.headline
        snippetView.fullURL = postData.fullURL
        snippetView.currentSnippetId = postData.id
        
        snippetView.setNeedsLayout()
        snippetView.layoutIfNeeded()
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
    
    func loadImageData(snippetView: SnippetView, postData: PostData)
    {
        snippetView.postImage.image = nil
        if (postData.image._gotImageData)
        {
            snippetView.postImageHeightConstraint.constant = postData.image._imageHeight
            snippetView.postImage.image = postData.image.getImageData()
        }
    }
    
    func loadSnippetFromID(snippetView : SnippetView, snippetID: Int, shouldTruncate: Bool)
    {
        for i in 0...postDataArray.count-1
        {
            if (postDataArray[i].id == snippetID)
            {
                let postData = postDataArray[i]
                loadDataIntoSnippet(snippetView: snippetView, shouldTruncate: shouldTruncate, postData: postData)
            }
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
        
        let singleTapRecognizerPostTimeAndAuthor : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        snippetView.postTimeAndWriter.isUserInteractionEnabled = true
        snippetView.postTimeAndWriter.addGestureRecognizer(singleTapRecognizerPostTimeAndAuthor)
        
        let singleTapRecognizerReferences : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        snippetView.references.isUserInteractionEnabled = true
        snippetView.references.addGestureRecognizer(singleTapRecognizerReferences)
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
