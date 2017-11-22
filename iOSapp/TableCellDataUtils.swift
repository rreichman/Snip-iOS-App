//
//  CellTextUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

func retrievePostImage(cell : SnippetTableViewCell, postData : PostData)
{
    do
    {
        _ = try cell.postImage.imageFromServerURL(urlString: postData.image._imageURL)
    }
    catch is ProgramError
    {
        // Currently doesn't handle failed loads of data
    }
    catch
    {
        // All is good
    }
}

func fillImageDescription(cell : SnippetTableViewCell, postData : PostData)
{
    let imageDescriptionAttributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().IMAGE_DESCRIPTION_TEXT_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().IMAGE_DESCRIPTION_COLOR]
    let imageDescriptionString : NSMutableAttributedString = NSMutableAttributedString(htmlString : postData.image._imageDescription)!
    imageDescriptionString.addAttributes(imageDescriptionAttributes, range: NSRange(location: 0,length: imageDescriptionString.length))
    
    cell.imageDescription.attributedText = imageDescriptionString
    // Make the link in image description gray
    cell.imageDescription.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : SystemVariables().IMAGE_DESCRIPTION_COLOR]
    removePaddingFromTextView(textView: cell.imageDescription)
}

func getTextAfterTruncation(tableViewCell : SnippetTableViewCell, rowWidth: Float, font : UIFont) -> NSAttributedString
{
    let text : NSAttributedString = tableViewCell.body.attributedText!
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
        tableViewCell.isTextLongEnoughToBeTruncated = true
    }
    else
    {
        truncatedText = text.mutableCopy() as! NSMutableAttributedString
        tableViewCell.isTextLongEnoughToBeTruncated = false
    }
    truncatedText.addAttribute(NSAttributedStringKey.font, value: font, range: NSRange(location: 0,length: truncatedText.length))
    
    return truncatedText
}

func setCellText(tableViewCell : SnippetTableViewCell, postDataArray : [PostData], indexPath : IndexPath, shouldTruncate : Bool)
{
    let postData = postDataArray[indexPath.row]
    
    let cellFont : UIFont = SystemVariables().CELL_TEXT_FONT!
    tableViewCell.body.attributedText = getCellTextStyle(cellText: postData.text, indexPath: indexPath, font : cellFont)
    
    let rowWidth = tableViewCell.body.bounds.size.width
    let widthOfSingleChar = getWidthOfSingleChar(string: tableViewCell.body.attributedText!)
    let sizeOfRowInChars = Float(rowWidth) / widthOfSingleChar
    
    if (shouldTruncate)
    {
        tableViewCell.body.attributedText = getTextAfterTruncation(tableViewCell: tableViewCell, rowWidth: sizeOfRowInChars, font : cellFont)
        tableViewCell.references.attributedText = NSAttributedString()
    }
    else
    {
        addReferencesStringsToCell(cell : tableViewCell, postData: postData)
        // TODO:: there's a bug here that I don't make the likes appear but moving the likes anyway
    }
    
    tableViewCell.likeButton.isHidden = shouldTruncate
    tableViewCell.dislikeButton.isHidden = shouldTruncate
    setStateOfReferencesHeightConstraint(references: tableViewCell.references, state: shouldTruncate)
    
    tableViewCell.body.isEditable = false
    removePaddingFromTextView(textView: tableViewCell.body)
}

func getCellTextStyle(cellText : String, indexPath: IndexPath, font : UIFont) -> NSMutableAttributedString
{
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.hyphenationFactor = 1.0
    paragraphStyle.lineSpacing = SystemVariables().LINE_SPACING_IN_TEXT
    let text = NSMutableAttributedString(htmlString : cellText, font : font)!
    text.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: text.length))
    
    return text
}

func fillPublishTimeAndWriterInfo(cell : SnippetTableViewCell, postData : PostData)
{
    let publishTimeAndWriterAttributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().PUBLISH_TIME_AND_WRITER_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().PUBLISH_TIME_AND_WRITER_COLOR]
    cell.postTimeAndWriter.attributedText = NSAttributedString(string : getTimeAndWriterStringFromDateString(dateString: postData.date, author : postData.author._authorName), attributes: publishTimeAndWriterAttributes)
    removePaddingFromTextView(textView: cell.postTimeAndWriter)
}

func setStateOfReferencesHeightConstraint(references : UITextView, state : Bool)
{
    for constraint in references.constraints
    {
        if constraint.identifier == "referencesHeightConstraint"
        {
            constraint.isActive = state
        }
    }
}

func getReferencesStringFromPostData(postData : PostData) -> NSMutableAttributedString
{
    var isFirstReference : Bool = true
    let referencesString = NSMutableAttributedString()
    
    for reference in postData.relatedLinks
    {
        if (!isFirstReference)
        {
            referencesString.append(NSAttributedString(string : "\n"))
        }
        isFirstReference = false
        
        let title : String = reference["title"] as! String
        let referenceAttributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().REFERENCES_FONT!]
        let referenceString = NSMutableAttributedString(string: title, attributes: referenceAttributes)
        referenceString.addAttribute(.link, value: reference["link"]!, range: NSRange(location:0, length: title.count))
        
        referencesString.append(referenceString)
    }
    return referencesString
}

func addReferencesStringsToCell(cell: SnippetTableViewCell, postData: PostData)
{
    let allReferencesString = getReferencesStringFromPostData(postData: postData)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = SystemVariables().LINE_SPACING_IN_REFERENCES
    allReferencesString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: allReferencesString.length))
    
    cell.references.attributedText = allReferencesString
    cell.references.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : SystemVariables().REFERENCES_COLOR]
    removePaddingFromTextView(textView: cell.references)
}
