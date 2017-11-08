//
//  FeedDataSource.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/29/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import ReadMoreTextView

class FeedDataSource: NSObject, UITableViewDataSource
{
    var postDataArray: [PostData] = []
    var _tableView: UITableView = UITableView()
    
    public func getLinkAttributesForWebsite(linkWebsite : String) -> [String : Any]
    {
        let linkAttributes = [
            NSAttributedStringKey.link.rawValue: NSURL(string: linkWebsite)!,
            NSAttributedStringKey.foregroundColor: UIColor.blue
            ] as! [String : Any]
        return linkAttributes
    }
    
    public func addPost(newPost : PostData)
    {
        postDataArray.append(newPost)
    }
    
    public func getLastIndexOfSubstringInString(originalString : String, substring : String) -> Int
    {
        return (originalString.range(of: substring, options: .backwards)?.lowerBound.encodedOffset)!
    }
    
    public func getTextAfterTruncation(text : String, contentSizeOfRow: Float) -> String
    {
        var truncatedText = text
        // Above this number of rows we want to truncate the snippet because it's too long
        let NUMBER_OF_ROWS_TO_TRUNCATE = 5
        let NUMBER_OF_ROWS_IN_PREVIEW = 2
        
        let READ_MORE_TEXT = "... Read More"
        
        let MAX_LENGTH_TO_TRUNCATE = Int(floor(Float(contentSizeOfRow) * Float(NUMBER_OF_ROWS_TO_TRUNCATE)))

        let PREVIEW_SIZE = Int(floor(Float(contentSizeOfRow) * Float(NUMBER_OF_ROWS_IN_PREVIEW))) - READ_MORE_TEXT.count
        
        if (text.count >= MAX_LENGTH_TO_TRUNCATE)
        {
            truncatedText = String(text.prefix(PREVIEW_SIZE))
            truncatedText.append(READ_MORE_TEXT)
        }
        
        return truncatedText
    }
    
    func getWIdthOfSingleChar(font : UIFont) -> Int
    {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let myText = "a"
        
        return Int((myText as NSString).size(withAttributes: fontAttributes).width)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return postDataArray.count
    }
    
    @objc func textLabelPressed(sender: UITapGestureRecognizer)
    {
        let indexPath = _tableView.indexPathForRow(at: sender.location(in: _tableView))
        let cell = _tableView.cellForRow(at: indexPath!) as! MealTableViewCell
        let cellOriginalText = cell.cellText.text
        
        cell.shouldTruncateText = !cell.shouldTruncateText
        setCellText(tableViewCell: cell, postDataArray: postDataArray, indexPath: indexPath!)
        
        let cellUpdatedText = cell.cellText.text
        if (cellUpdatedText != cellOriginalText)
        {
            _tableView.reloadData()
        }
        print("pressed label")
    }
    
    func makeCellClickable(tableViewCell : MealTableViewCell)
    {
        let singleTapRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.cellText.isUserInteractionEnabled = true
        tableViewCell.cellText.addGestureRecognizer(singleTapRecognizer)
    }
    
    func setCellText(tableViewCell : MealTableViewCell, postDataArray : [PostData], indexPath : IndexPath)
    {
        let postData = postDataArray[indexPath[1]]
        
        tableViewCell.cellText.lineBreakMode = NSLineBreakMode.byTruncatingMiddle;
        tableViewCell.cellText.numberOfLines = 0;
        
        let cellFont = UIFont(name: "Helvetica", size: 14)
        // TODO:: handle font failure?
        tableViewCell.cellText.font = cellFont
        
        let rowWidth = tableViewCell.cellText.bounds.size.width
        let sizeOfRowInChars = floor(Float(rowWidth) / Float(getWIdthOfSingleChar(font: cellFont!)))
        
        var textAfterTruncation : String = getTextAfterTruncation(text: postData._text, contentSizeOfRow: sizeOfRowInChars)
        if (!tableViewCell.shouldTruncateText)
        {
            textAfterTruncation = postData._text
        }
        tableViewCell.cellText.attributedText = getCellTextStyle(cellText: textAfterTruncation, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        _tableView = tableView
        //handleInfiniteScroll(tableView : tableView, currentRow: indexPath.row);
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MealTableViewCell
        let postData = postDataArray[indexPath[1]]
        tableView.allowsSelection = false
        
        makeCellClickable(tableViewCell : cell)
        setCellText(tableViewCell : cell, postDataArray : postDataArray, indexPath: indexPath)
        
        cell.cellHeadline.font = UIFont.boldSystemFont(ofSize: cell.cellHeadline.font.pointSize)
        cell.cellHeadline.text = postData._headline
        
        do
        {
            _ = try cell.cellImage.imageFromServerURL(urlString: postData._image._imageURL)
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
        let text : NSAttributedString = NSAttributedString(htmlString : cellText)!
        let mutableText : NSMutableAttributedString = text.mutableCopy() as! NSMutableAttributedString
        mutableText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: text.length))
        
        return mutableText
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
        // TODO:: actually get data from website instead of adding noise
        /*addPost(
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
            headline: "headline16", text: "text8", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")*/
    }
    
    func deleteRowSafelyFromTable(currentLocation : Int)
    {
        // Need data reload?
        //postDataArray.remove(at: currentLocation)
    }
}
