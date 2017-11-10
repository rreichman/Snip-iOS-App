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
    var _tableView: UITableView = UITableView()
    var setOfCellsNotToTruncate : Set<Int> = Set<Int>()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        _tableView = tableView
        //handleInfiniteScroll(tableView : tableView, currentRow: indexPath.row);
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MealTableViewCell
        let postData = postDataArray[indexPath[1]]
        tableView.allowsSelection = false
        
        makeCellClickable(tableViewCell : cell)
        setCellText(tableViewCell : cell, postDataArray : postDataArray, indexPath: indexPath, shouldTruncate: !setOfCellsNotToTruncate.contains(indexPath[1]))
        
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
    
    public func getTextAfterTruncation(text : NSAttributedString, rowWidth: Float, font : UIFont) -> NSAttributedString
    {
        // Above this number of rows we want to truncate the snippet because it's too long
        let NUMBER_OF_ROWS_TO_TRUNCATE = 6
        let NUMBER_OF_ROWS_IN_PREVIEW = 2
        
        let READ_MORE_TEXT : NSAttributedString = NSAttributedString(string : "... Read More")
        let SPARE_IN_ADDITION_TO_READ_MORE_LENGTH = 7
        
        let MAX_LENGTH_TO_TRUNCATE = Int(floor(Float(rowWidth) * Float(NUMBER_OF_ROWS_TO_TRUNCATE)))

        let PREVIEW_SIZE = Int(floor(Float(rowWidth) * Float(NUMBER_OF_ROWS_IN_PREVIEW))) - READ_MORE_TEXT.length - SPARE_IN_ADDITION_TO_READ_MORE_LENGTH
        
        var truncatedText = NSMutableAttributedString()
        if (text.length >= MAX_LENGTH_TO_TRUNCATE)
        {
            let substring = text.attributedSubstring(from: NSRange(location: 0,length: PREVIEW_SIZE))
            truncatedText.append(substring)
            truncatedText.append(READ_MORE_TEXT)
        }
        else
        {
            truncatedText = text.mutableCopy() as! NSMutableAttributedString
        }
        truncatedText.addAttribute(NSAttributedStringKey.font, value: font, range: NSRange(location: 0,length: truncatedText.length))
        
        return truncatedText
    }
    
    func getWidthOfSingleChar(string : NSAttributedString) -> Float
    {
        let NUMBER_OF_CHARS_TO_CHECK = min(60,string.length)
        let firstXChars : NSAttributedString = string.attributedSubstring(from: NSRange(location: 0,length: NUMBER_OF_CHARS_TO_CHECK))
        return (Float(firstXChars.size().width) / Float(NUMBER_OF_CHARS_TO_CHECK))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return postDataArray.count
    }
    
    @objc func textLabelPressed(sender: UITapGestureRecognizer)
    {
        let indexPath = _tableView.indexPathForRow(at: sender.location(in: _tableView))
        print(indexPath![0])
        print(indexPath![1])
        
        if (setOfCellsNotToTruncate.contains(indexPath![1]))
        {
            print("removing cell \(indexPath![1])")
            setOfCellsNotToTruncate.remove(indexPath![1])
        }
        else
        {
            print("adding cell \(indexPath![1])")
            setOfCellsNotToTruncate.insert(indexPath![1])
        }
        
        print("reloading cell \(indexPath![1])")
        UIView.performWithoutAnimation
        {
            _tableView.beginUpdates()
            _tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.none)
            _tableView.endUpdates()
        }

        print("pressed label")
    }
    
    func makeCellClickable(tableViewCell : MealTableViewCell)
    {
        let singleTapRecognizerText : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.cellText.isUserInteractionEnabled = true
        tableViewCell.cellText.addGestureRecognizer(singleTapRecognizerText)
        let singleTapRecognizerHeadline : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.cellHeadline.isUserInteractionEnabled = true
        tableViewCell.cellHeadline.addGestureRecognizer(singleTapRecognizerHeadline)
    }
    
    func setCellText(tableViewCell : MealTableViewCell, postDataArray : [PostData], indexPath : IndexPath, shouldTruncate : Bool)
    {
        let postData = postDataArray[indexPath[1]]
        
        let cellFont : UIFont = UIFont(name: "Helvetica", size: 13)!
        tableViewCell.cellText.attributedText = getCellTextStyle(cellText: postData._text, indexPath: indexPath, font : cellFont)
        let rowWidth = tableViewCell.cellText.bounds.size.width
        let widthOfSingleChar = getWidthOfSingleChar(string: tableViewCell.cellText.attributedText!)
        let sizeOfRowInChars = Float(rowWidth) / widthOfSingleChar
    
        if (shouldTruncate)
        {
            let textAfterTruncation : NSAttributedString = getTextAfterTruncation(text: tableViewCell.cellText.attributedText!, rowWidth: sizeOfRowInChars, font : cellFont)
            tableViewCell.cellText.attributedText = textAfterTruncation
        }
        tableViewCell.cellText.isEditable = false
    }
    
    func getCellTextStyle(cellText : String, indexPath: IndexPath, font : UIFont) -> NSMutableAttributedString
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        let text : NSAttributedString = NSAttributedString(htmlString : cellText, font : font)!
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
    
    /*func deleteRowSafelyFromTable(currentLocation : Int)
    {
        // Need data reload?
        //postDataArray.remove(at: currentLocation)
    }*/
    
    /*public func getLastIndexOfSubstringInString(originalString : String, substring : String) -> Int
     {
     return (originalString.range(of: substring, options: .backwards)?.lowerBound.encodedOffset)!
     }*/
}
