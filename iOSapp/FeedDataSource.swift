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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let postData = postDataArray[indexPath[1]]
        tableView.allowsSelection = false
        
        getPostImage(cell: cell, postData: postData)
        fillImageDescription(cell: cell, postData: postData)
        fillPublishTimeAndWriterInfo(cell: cell, postData: postData)
        
        makeCellClickable(tableViewCell : cell)
        setCellText(tableViewCell : cell, postDataArray : postDataArray, indexPath: indexPath, shouldTruncate: !setOfCellsNotToTruncate.contains(indexPath[1]))
        
        cell.headline.font = SystemVariables().HEADLINE_TEXT_FONT
        cell.headline.text = postData._headline
        
        turnLikeImageIntoButton(cell: cell)
        
        return cell
    }
    
    @objc func handleClickOnLike(sender : UITapGestureRecognizer)
    {
        var imageViewWithMetadata = sender.view as! UIImageViewWithMetadata
        // TODO:: handle errors here
        
        if (imageViewWithMetadata.isClicked)
        {
            imageViewWithMetadata.image = #imageLiteral(resourceName: "thumbsUp")
            imageViewWithMetadata.isClicked = false
            // TODO:: Manage unlike click
        }
        else
        {
            imageViewWithMetadata.image = #imageLiteral(resourceName: "thumbsUpClicked")
            imageViewWithMetadata.isClicked = true
            // TODO:: Manage like click
        }
    }
    
    func turnLikeImageIntoButton(cell : TableViewCell)
    {
        let likeButtonClickRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleClickOnLike(sender:)))
        cell.likeButton.isUserInteractionEnabled = true
        cell.likeButton.addGestureRecognizer(likeButtonClickRecognizer)
    }
    
    func fillImageDescription(cell : TableViewCell, postData : PostData)
    {
        let imageDescriptionAttributes = [NSAttributedStringKey.font : SystemVariables().IMAGE_DESCRIPTION_TEXT_FONT, NSAttributedStringKey.foregroundColor : SystemVariables().IMAGE_DESCRIPTION_COLOR]
        let imageDescriptionString : NSMutableAttributedString = NSMutableAttributedString(htmlString : postData._image._imageDescription)!
        imageDescriptionString.addAttributes(imageDescriptionAttributes, range: NSRange(location: 0,length: imageDescriptionString.length))
        
        cell.imageDescription.attributedText = imageDescriptionString
        // Make the link in image description gray
        cell.imageDescription.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : SystemVariables().IMAGE_DESCRIPTION_COLOR]
        removePaddingFromTextView(textView: cell.imageDescription)
    }
    
    func fillPublishTimeAndWriterInfo(cell : TableViewCell, postData : PostData)
    {
        let publishTimeAndWriterAttributes = [NSAttributedStringKey.font : SystemVariables().PUBLISH_TIME_AND_WRITER_FONT, NSAttributedStringKey.foregroundColor : SystemVariables().PUBLISH_TIME_AND_WRITER_COLOR]
        cell.postTimeAndWriter.attributedText = NSAttributedString(string : getTimeAndWriterStringFromDateString(dateString: postData._date, author : postData._author._authorName), attributes: publishTimeAndWriterAttributes)
        removePaddingFromTextView(textView: cell.postTimeAndWriter)
    }
    
    func getPostImage(cell : TableViewCell, postData : PostData)
    {
        do
        {
            _ = try cell.postImage.imageFromServerURL(urlString: postData._image._imageURL)
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
    }
    
    func addReferencesStrings(cell: TableViewCell, postData: PostData)
    {
        var isFirstReference : Bool = true
        
        let allReferencesString = NSMutableAttributedString()
        
        for reference in postData._relatedLinks
        {
            if (!isFirstReference)
            {
                allReferencesString.append(NSAttributedString(string : "\n"))
            }
            isFirstReference = false
            
            let title : String = reference["title"] as! String
            let referenceAttributes = [NSAttributedStringKey.font : SystemVariables().REFERENCES_FONT]
            let referenceString = NSMutableAttributedString(string: reference["title"] as! String, attributes: referenceAttributes)
            referenceString.addAttribute(.link, value: reference["link"], range: NSRange(location:0, length: title.count))
                
            allReferencesString.append(referenceString)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = SystemVariables().LINE_SPACING_IN_REFERENCES
        allReferencesString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: allReferencesString.length))
        
        cell.references.attributedText = allReferencesString
        cell.references.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : SystemVariables().REFERENCES_COLOR]
        removePaddingFromTextView(textView: cell.references)
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
        let READ_MORE_TEXT : NSAttributedString = NSAttributedString(string : "... Read More", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray])
        let SPARE_IN_ADDITION_TO_READ_MORE_LENGTH = 15
        
        let MAX_LENGTH_TO_TRUNCATE = Int(floor(Float(rowWidth) * Float(SystemVariables().NUMBER_OF_ROWS_TO_TRUNCATE)))

        let PREVIEW_SIZE = Int(floor(Float(rowWidth) * Float(SystemVariables().NUMBER_OF_ROWS_IN_PREVIEW))) - READ_MORE_TEXT.length - SPARE_IN_ADDITION_TO_READ_MORE_LENGTH
        
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
    
    func myCompletionHandler(_ success: Bool)
    {
        print("here")
    }
    
    func handleClickedLink(linkURL : NSURL)
    {
        UIApplication.shared.open(linkURL as URL, options: [:], completionHandler: nil)
    }
    
    // Returns if the operation was handled
    func handleClickOnTextView(sender: UITapGestureRecognizer) -> Bool
    {
        let textView : UITextView = sender.view as! UITextView
        let layoutManager : NSLayoutManager = textView.layoutManager
        var location : CGPoint = sender.location(in: textView)
        location.x -= textView.textContainerInset.left;
        location.y -= textView.textContainerInset.top;
        let characterIndex : Int = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        var attributes : [NSAttributedStringKey : Any] = textView.attributedText.attributes(at: characterIndex, longestEffectiveRange: nil, in: NSRange(location: characterIndex, length: characterIndex + 1))
        for attribute in attributes
        {
            if attribute.key._rawValue == "NSLink"
            {
                handleClickedLink(linkURL: attribute.value as! NSURL)
                return true
            }
        }
        return false
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
        
        if (setOfCellsNotToTruncate.contains(indexPath![1]))
        {
            setOfCellsNotToTruncate.remove(indexPath![1])
        }
        else
        {
            setOfCellsNotToTruncate.insert(indexPath![1])
        }
    
        UIView.performWithoutAnimation
        {
            _tableView.beginUpdates()
            _tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.none)
            _tableView.endUpdates()
        }

        print("pressed label")
    }
    
    func makeCellClickable(tableViewCell : TableViewCell)
    {
        let singleTapRecognizerText : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.body.isUserInteractionEnabled = true
        tableViewCell.body.addGestureRecognizer(singleTapRecognizerText)
        
        let singleTapRecognizerHeadline : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.headline.isUserInteractionEnabled = true
        tableViewCell.headline.addGestureRecognizer(singleTapRecognizerHeadline)
        
        let singleTapRecognizerPostTimeAndAuthor : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.textLabelPressed(sender:)))
        tableViewCell.postTimeAndWriter.isUserInteractionEnabled = true
        tableViewCell.postTimeAndWriter.addGestureRecognizer(singleTapRecognizerPostTimeAndAuthor)
    }
    
    func setCellText(tableViewCell : TableViewCell, postDataArray : [PostData], indexPath : IndexPath, shouldTruncate : Bool)
    {
        let postData = postDataArray[indexPath[1]]
        
        let cellFont : UIFont = SystemVariables().CELL_TEXT_FONT!
        tableViewCell.body.attributedText = getCellTextStyle(cellText: postData._text, indexPath: indexPath, font : cellFont)
        addReferencesStrings(cell : tableViewCell, postData: postData)
        
        let rowWidth = tableViewCell.body.bounds.size.width
        // For some reason the row width expands when I click read more. why? constraints missing?
        let widthOfSingleChar = getWidthOfSingleChar(string: tableViewCell.body.attributedText!)
        let sizeOfRowInChars = Float(rowWidth) / widthOfSingleChar
    
        if (shouldTruncate)
        {
            let textAfterTruncation : NSAttributedString = getTextAfterTruncation(text: tableViewCell.body.attributedText!, rowWidth: sizeOfRowInChars, font : cellFont)
            tableViewCell.body.attributedText = textAfterTruncation
            tableViewCell.likeButton.isHidden = true
            tableViewCell.references.isHidden = true
        }
        else
        {
            tableViewCell.likeButton.isHidden = false
            tableViewCell.references.isHidden = false
        }
        
        tableViewCell.body.isEditable = false
        removePaddingFromTextView(textView: tableViewCell.body)
    }
    
    func getCellTextStyle(cellText : String, indexPath: IndexPath, font : UIFont) -> NSMutableAttributedString
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        paragraphStyle.lineSpacing = SystemVariables().LINE_SPACING_IN_TEXT
        let text = NSMutableAttributedString(htmlString : cellText, font : font)!
        //let mutableText : NSMutableAttributedString = text.mutableCopy() as! NSMutableAttributedString
        text.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: text.length))
        
        return text
    }
    
    func handleInfiniteScroll(tableView : UITableView, currentRow : Int)
    {
        let SPARE_ROWS_UNTIL_MORE_SCROLL = 3
        if postDataArray.count - currentRow < SPARE_ROWS_UNTIL_MORE_SCROLL
        {
            //loadMorePostsToTable()
            //tableView.reloadData()
        }
    }
    
    /*public func getLastIndexOfSubstringInString(originalString : String, substring : String) -> Int
     {
     return (originalString.range(of: substring, options: .backwards)?.lowerBound.encodedOffset)!
     }*/
}
