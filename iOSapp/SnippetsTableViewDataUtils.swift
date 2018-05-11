//
//  SnippetsTableViewDataUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/26/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import Cache

extension SnippetsTableViewController
{
    func getRestOfImagesAsync()
    {
        let storage = AppCache.shared.getStorage()
        
        for postData in _postDataArray
        {
            if !postData.image._gotImageData
            {
                if let cachedImage = try? storage.object(ofType: ImageWrapper.self, forKey: postData.image._imageURL).image
                {
                    postData.image.setImageData(imageData: cachedImage)
                }
                else
                {
                    DispatchQueue.global(qos: .background).async
                        {
                            let url = NSURL(string:postData.image._imageURL)
                            let data = NSData(contentsOf:url! as URL)
                            if data != nil
                            {
                                postData.image.setImageData(imageData: UIImage(data:data! as Data)!)
                            }
                    }
                }
            }
        }
    }
    
    func collectionErrorHandler()
    {
        DispatchQueue.main.async
            {
                if (self.tableView.refreshControl?.isRefreshing)!
                {
                    self.tableView.refreshControl?.endRefreshing()
                }
                
                if (self.activityIndicator.isAnimating)
                {
                    self.activityIndicator.stopAnimating()
                }
        }
    }
    
    func fillSnippetViewController()
    {
        snipRetrieverFromWeb.getSnipsJsonFromWebServer(completionHandler: self.dataCollectionCompletionHandler, appendDataAndNotReplace: false, errorHandler: self.collectionErrorHandler)
    }
    
    func dataCollectionCompletionHandler(postsCollected: [PostData], appendDataAndNotReplace : Bool)
    {
        DispatchQueue.main.async
            {
                if (self.tableView.refreshControl != nil)
                {
                    if (self.tableView.refreshControl?.isRefreshing)!
                    {
                        self.tableView.refreshControl?.endRefreshing()
                    }
                }
                
                self._postDataArray =
                    WebUtils.shared.addPostsToFeed(snipRetriever: self.snipRetrieverFromWeb, originalPostDataArray: self._postDataArray, postsToAdd: postsCollected, appendDataAndNotReplace : appendDataAndNotReplace)
                self.getRestOfImagesAsync()
                self.tableView.reloadData()
                self.finishedLoadingSnippets = true
                
                if (self.activityIndicator.isAnimating)
                {
                    self.activityIndicator.stopAnimating()
                }
                
                if (self.shouldEnterCommentOfFirstSnippet)
                {
                    let firstCell : SnippetTableViewCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SnippetTableViewCell
                    firstCell.snippetView.operateHandleClickOnComment(tableView: self.tableView, rowCurrentlyClicked: 0)
                    print("entered first comment")
                    self.shouldEnterCommentOfFirstSnippet = false
                }
        }
    }
    
    func operateRefresh(newBaseUrlString: String, newQuery: String, useActivityIndicator: Bool)
    {
        print("refresh")
        
        if (useActivityIndicator)
        {
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        }
        Logger().logRefreshOfTableView()
        snipRetrieverFromWeb.clean(newUrlString: newBaseUrlString, newQuery: newQuery)
        fillSnippetViewController()
        scrollToTopOfTable()
    }
    
    @objc func refresh(_ sender: UIRefreshControl)
    {
        operateRefresh(newBaseUrlString: snipRetrieverFromWeb.baseURLString, newQuery: snipRetrieverFromWeb.urlQuery, useActivityIndicator: false)
    }
    
    func updatePostDataAfterClick(snippetID : Int, upvoteButton: UIImageViewWithMetadata, downvoteButton: UIImageViewWithMetadata)
    {
        for postData in _postDataArray
        {
            if (postData.id == snippetID)
            {
                postData.isLiked = upvoteButton.isClicked
                postData.isDisliked = downvoteButton.isClicked
            }
        }
    }
    
    func getForegroundSnippetIDs() -> [Int]
    {
        let indexPathsForVisibleRows : [IndexPath] = tableView.indexPathsForVisibleRows!
        let numberOfVisibleRows = indexPathsForVisibleRows.count
        
        if numberOfVisibleRows == 2
        {
            return [_postDataArray[indexPathsForVisibleRows[0].row].id]
        }
        
        var snippetIDs : [Int] = []
        
        if numberOfVisibleRows > 2
        {
            // Getting all the middle rows
            for i in 0...numberOfVisibleRows-1
            {
                snippetIDs.append(_postDataArray[indexPathsForVisibleRows[i].row].id)
            }
        }
        else
        {
            Logger().logWeirdNumberOfSnippetsOnScreen(numberOfSnippets : numberOfVisibleRows)
        }
        
        return snippetIDs
    }
    
    func loadDataIntoSnippet(snippetView: SnippetView, shouldTruncate: Bool, postData: PostData)
    {
        snippetView.setUpvoteDownvoteImagesAccordingtoVote(snippetView: snippetView, postData : postData)
        
        snippetView.writerPostTime.attributedText = postData.timeString
        snippetView.writerName.attributedText = postData.writerString
        snippetView.writerUsername = postData.author._username
        
        // TODO: this needs to update when user deletes a comment, make it a generic function.
        snippetView.numberOfCommentsLabel.attributedText = postData.attributedStringOfCommentCount
        
        loadImageData(snippetView: snippetView, postData: postData)
        
        fillImageDescription(snippetView: snippetView, imageDescription: postData.imageDescriptionAfterHtmlRendering)
        
        snippetView.makeSnippetClickable(snippetView: snippetView)
        snippetView.isTextLongEnoughToBeTruncated = postData.m_isTextLongEnoughToBeTruncated
        
        snippetView.truncatedBody = postData.textAsAttributedStringWithTruncation
        snippetView.nonTruncatedBody = postData.textAsAttributedStringWithoutTruncation
        
        setSnippetText(snippetView: snippetView, postData : postData, shouldTruncate: shouldTruncate)
        
        setSnippetReferences(snippetView : snippetView, postData: postData, shouldTruncate: shouldTruncate, isTextLongEnoughToBeTruncated:
            postData.m_isTextLongEnoughToBeTruncated)
        
        setSnippetHeadline(snippetView: snippetView, postData : postData)
        
        snippetView.fullURL = postData.fullURL
        snippetView.currentSnippetId = postData.id
    }
    
    func loadImageData(snippetView: SnippetView, postData: PostData)
    {
        snippetView.postImage.image = nil
        if (postData.image._gotImageData)
        {
            if (postData.image._imageHeight.isNaN)
            {
                snippetView.postImageHeightConstraint.constant = 0
                snippetView.imageDescription.text = ""
            }
            else
            {
                snippetView.postImageHeightConstraint.constant = postData.image._imageHeight
            }
            snippetView.postImage.image = postData.image.getImageData()
        }
        else
        {
            snippetView.postImageHeightConstraint.constant = 0
            snippetView.imageDescription.text = ""
        }
    }
    
    func loadSnippetFromID(snippetView : SnippetView, snippetID: Int, shouldTruncate: Bool)
    {
        for i in 0..._postDataArray.count-1
        {
            if (_postDataArray[i].id == snippetID)
            {
                let postData = _postDataArray[i]
                loadDataIntoSnippet(snippetView: snippetView, shouldTruncate: shouldTruncate, postData: postData)
            }
        }
    }
    
    func getSnippetComments(snippetID : Int) -> [Comment]
    {
        for i in 0..._postDataArray.count-1
        {
            if (_postDataArray[i].id == snippetID)
            {
                return _postDataArray[i].comments
            }
        }
        
        return []
    }
    
    func setSnippetComments(snippetID : Int, newComments : [Comment])
    {
        for i in 0..._postDataArray.count-1
        {
            if (_postDataArray[i].id == snippetID)
            {
                let newPostData = _postDataArray[i]
                newPostData.comments = newComments
                _postDataArray[i] = newPostData
            }
        }
    }
}

