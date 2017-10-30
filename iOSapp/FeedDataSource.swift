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
    
    public func addPost(headline : String, text : String, imageURL : String)
    {
        let newPost = PostData(headline: headline, text: text, imageURL: imageURL)
        postDataArray.append(newPost)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return postDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        handleInfiniteScroll(tableView : tableView, currentRow: indexPath.row);
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MealTableViewCell
        let currentPostData = postDataArray[indexPath[1]]
        tableView.allowsSelection = false
        
        cell.cellText.lineBreakMode = NSLineBreakMode.byTruncatingMiddle;
        cell.cellText.numberOfLines = 0;
        cell.cellText.attributedText = getCellTextStyle(cellText: currentPostData._text, indexPath: indexPath)
        cell.cellText.font = cell.cellText.font.withSize(14)
        
        cell.cellHeadline.font = UIFont.boldSystemFont(ofSize: cell.cellHeadline.font.pointSize)
        cell.cellHeadline.text = currentPostData._headline
        
        do
        {
            _ = try cell.cellImage.imageFromServerURL(urlString: currentPostData._imageURL)
        }
        catch is ProgramError
        {
            // TODO:: currently doesn't handle failed loads of data
            // deleteRowSafelyFromTable(currentLocation: indexPath[1])
        }
        catch
        {
            // All is good
        }
        
        return cell
    }
    
    func getCellTextStyle(cellText : String, indexPath: IndexPath) -> NSMutableAttributedString
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        return NSMutableAttributedString(string: cellText, attributes: [NSAttributedStringKey.paragraphStyle:paragraphStyle])
    }
    
    func handleInfiniteScroll(tableView : UITableView, currentRow : Int)
    {
        let SPARE_ROWS_UNTIL_MORE_SCROLL = 3
        if postDataArray.count - currentRow < SPARE_ROWS_UNTIL_MORE_SCROLL
        {
            loadMorePostsToTable()
            tableView.reloadData()
        }
    }
    
    func loadMorePostsToTable()
    {
        // TODO:: actually get data from website instead of adding spam
        addPost(
            headline: "headline9", text: "text1", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/pizza.png")
        addPost(
            headline: "headline10", text: "text2", imageURL: "https://upload.wikimedia.org/wikipedia/commons/7/79/San_Francisco–Oakland_Bay_Bridge-_New_and_Old_bridges.jpg")
        addPost(
            headline: "headline11", text: "text3", imageURL: "https://static.pexels.com/photos/7653/pexels-photo.jpeg")
        addPost(
            headline: "headline12", text: "text4", imageURL: "https://cdn.pixabay.com/photo/2017/04/08/00/31/usa-2212202_960_720.jpg")
        addPost(
            headline: "headline13", text: "text5", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")
        addPost(
            headline: "headline14", text: "text6", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")
        addPost(
            headline: "headline15", text: "text7", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")
        addPost(
            headline: "headline16", text: "text8", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")
    }
    
    func deleteRowSafelyFromTable(currentLocation : Int)
    {
        // Need data reload?
        //postDataArray.remove(at: currentLocation)
    }
}
