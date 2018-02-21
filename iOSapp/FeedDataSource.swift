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
        cell.snippetView.currentViewController = _tableView.delegate as! SnippetsTableViewController
        
        return cell
    }
    
    func loadDataIntoSnippet(snippetView: SnippetView, shouldTruncate: Bool, postData: PostData)
    {
        snippetView.setUpvoteDownvoteImagesAccordingtoVote(snippetView: snippetView, postData : postData)
        
        snippetView.writerPostTime.attributedText = postData.timeString
        snippetView.writerName.attributedText = postData.writerString
        
        // TODO:: this needs to update when user deletes a comment, make it a generic function.
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
}
