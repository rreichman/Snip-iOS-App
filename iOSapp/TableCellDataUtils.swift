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

func fillImageDescription(cell : SnippetTableViewCell, imageDescription : NSMutableAttributedString)
{
    cell.imageDescription.attributedText = imageDescription
    // Make the link in image description gray
    cell.imageDescription.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : SystemVariables().IMAGE_DESCRIPTION_COLOR]
    removePaddingFromTextView(textView: cell.imageDescription)
}

func setCellText(tableViewCell : SnippetTableViewCell, postData : PostData, shouldTruncate : Bool)
{
    tableViewCell.body.attributedText = getAttributedTextOfCell(tableViewCell : tableViewCell, postData: postData, shouldTruncate: shouldTruncate)
    let isTextCurrentlyTruncated : Bool = tableViewCell.isTextLongEnoughToBeTruncated && shouldTruncate
    
    tableViewCell.likeButton.isHidden = isTextCurrentlyTruncated
    tableViewCell.dislikeButton.isHidden = isTextCurrentlyTruncated
    tableViewCell.commentButton.isHidden = isTextCurrentlyTruncated
    
    removePaddingFromTextView(textView: tableViewCell.body)
}

func getAttributedTextOfCell(tableViewCell : SnippetTableViewCell, postData : PostData, shouldTruncate : Bool) -> NSMutableAttributedString
{
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.hyphenationFactor = 1.0
    paragraphStyle.lineSpacing = SystemVariables().LINE_SPACING_IN_TEXT
    paragraphStyle.paragraphSpacing = 7.0
    
    let text : NSMutableAttributedString = getAttributedTextAfterPossibleTruncation(tableViewCell : tableViewCell, postData : postData, shouldTruncate : shouldTruncate)
    
    if (tableViewCell.isTextLongEnoughToBeTruncated && shouldTruncate)
    {
        let READ_MORE_ATTRIBUTED_STRING = NSAttributedString(string: SystemVariables().READ_MORE_TEXT,
                                                             attributes : [NSAttributedStringKey.foregroundColor: SystemVariables().READ_MORE_TEXT_COLOR, NSAttributedStringKey.font : SystemVariables().READ_MORE_TEXT_FONT!])
        text.append(READ_MORE_ATTRIBUTED_STRING)
    }
    text.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: text.length))
    
    return text
}

func getAttributedTextAfterPossibleTruncation(tableViewCell : SnippetTableViewCell, postData : PostData, shouldTruncate : Bool) -> NSMutableAttributedString
{
    // Note - perhaps it would have been better to use the width of the table cell but that number subtly changes sometimes, creating annoying inconsistencies
    let screenWidth = CachedData().getScreenWidth()
    let widthOfSingleChar = getWidthOfSingleChar(font : SystemVariables().CELL_TEXT_FONT!)
    let sizeOfRowInChars = Float(screenWidth) / widthOfSingleChar
    
    let MAX_LENGTH_TO_TRUNCATE = Int(floor(Float(sizeOfRowInChars) * Float(SystemVariables().NUMBER_OF_ROWS_TO_TRUNCATE)))
    let PREVIEW_SIZE = Int(floor(Float(sizeOfRowInChars) * Float(SystemVariables().NUMBER_OF_ROWS_IN_PREVIEW))) - SystemVariables().READ_MORE_TEXT.count
    
    let text = postData.textAfterHtmlRendering
    
    var updatedText : NSMutableAttributedString = text
    if (text.length >= MAX_LENGTH_TO_TRUNCATE)
    {
        tableViewCell.isTextLongEnoughToBeTruncated = true
        if (shouldTruncate)
        {
            updatedText = text.attributedSubstring(from: NSRange(location: 0, length: PREVIEW_SIZE)).mutableCopy() as! NSMutableAttributedString
        }
    }
    else
    {
        tableViewCell.isTextLongEnoughToBeTruncated = false
    }
    
    let stringAttributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().CELL_TEXT_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().CELL_TEXT_COLOR]
    updatedText.addAttributes(stringAttributes, range: NSRange(location: 0, length: updatedText.length))
    return updatedText
}

func fillPublishTimeAndWriterInfo(cell : SnippetTableViewCell, postData : PostData)
{
    let publishTimeAndWriterAttributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().PUBLISH_TIME_AND_WRITER_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().PUBLISH_TIME_AND_WRITER_COLOR]
    let timeAndWriterString = getTimeFromDateString(dateString: postData.date) + ", by " + postData.author._name
    cell.postTimeAndWriter.attributedText = NSAttributedString(string : timeAndWriterString, attributes: publishTimeAndWriterAttributes)
    removePaddingFromTextView(textView: cell.postTimeAndWriter)
}

func setCellReferences(tableViewCell : SnippetTableViewCell, postData : PostData, shouldTruncate : Bool)
{
    if (tableViewCell.isTextLongEnoughToBeTruncated && shouldTruncate)
    {
        tableViewCell.references.attributedText = NSAttributedString()
    }
    else
    {
        addReferencesStringsToCell(cell : tableViewCell, postData: postData)
    }
    
    setStateOfReferencesHeightConstraint(references: tableViewCell.references, state: shouldTruncate)
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
