//
//  CellTextUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

/*func retrievePostImage(postData : PostData, isAsync : Bool) -> UIImage
{
    // I don't want it taking the data from a previous image.
    self.image = nil
    
    let storage = AppCache.shared.getStorage()
    /*if let cachedImage = try? storage.object(ofType: ImageWrapper.self, forKey: urlString).image
     {
     self.image = cachedImage
     handleHeightConstraint(cell: cell, image: cachedImage)
     return NoError()
     }*/
    
    if !isUrlValid(urlString: urlString)
    {
        throw ProgramError(errorMessage: "Invalid URL")
    }
    let url = NSURL(string: urlString)! as URL
    
    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
        if error != nil
        {
            print("error in loading URL")
            return
        }
        DispatchQueue.main.async(execute: { () -> Void in
            // Cache to image so it doesn't need to be reloaded every time the user scrolls and table cells are re-used.
            if let image = UIImage(data: data!)
            {
                let wrapper = ImageWrapper(image : image)
                try? storage.setObject(wrapper, forKey: urlString)
                self.image = image
                
                let ratio = image.size.width / CachedData().getScreenWidth()
                let newHeight = image.size.height / ratio
                cell.imageNecessaryHeight = newHeight
            }
        })
        
    }).resume()
        //_ = try cell.postImage.imageFromServerURL(cell: cell, urlString: postData.image._imageURL)
}*/

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
    
    setStateOfHeightConstraint(view: tableViewCell.references, identifier: "referencesHeightConstraint", state: tableViewCell.isTextLongEnoughToBeTruncated && shouldTruncate)
}

func setCellCommentPreview(tableViewCell: SnippetTableViewCell, postData: PostData, shouldTruncate: Bool)
{
    print("setting comments")
    var firstCommentWriter : String = ""
    var firstCommentText : String = ""
    
    if (postData.comments.count > 0)
    {
        firstCommentWriter = postData.comments[0].writer._name
        firstCommentText = postData.comments[0].body
    }
    
    let firstCommentFullString : String = firstCommentWriter + "\n" + firstCommentText
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = SystemVariables().LINE_SPACING_IN_COMMENT_PREVIEW
    
    let previewString : NSMutableAttributedString = NSMutableAttributedString(string: firstCommentFullString)
    previewString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: previewString.length))
    previewString.addAttributes([NSAttributedStringKey.font : SystemVariables().COMMENT_PREVIEW_AUTHOR_FONT], range: NSRange(location: 0, length: firstCommentWriter.count))
    
    tableViewCell.singleCommentPreview.attributedText = previewString
    
    let moreCommentsFullString = getMoreCommentsFullString(postData: postData)
    
    let moreCommentsAttributedString : NSMutableAttributedString = NSMutableAttributedString(string: moreCommentsFullString)
    moreCommentsAttributedString.setAttributes([NSAttributedStringKey.foregroundColor : UIColor.gray], range: NSRange(location: 0,length: moreCommentsAttributedString.length))
    
    tableViewCell.moreCommentsPreview.attributedText = moreCommentsAttributedString
    
    setVisibilityForCommentPreview(tableViewCell: tableViewCell, postData: postData, shouldTruncate: shouldTruncate)
}

func getMoreCommentsFullString(postData: PostData) -> String
{
    if (postData.comments.count == 1)
    {
        return ""
    }
    
    var moreCommentsString : String = " more comments..."
    
    if (postData.comments.count == 2)
    {
        moreCommentsString = " more comment..."
    }
    
    return "" + String(postData.comments.count - 1) + moreCommentsString
}

func setVisibilityForCommentPreview(tableViewCell: SnippetTableViewCell, postData: PostData, shouldTruncate: Bool)
{
    // Note - This (no preview) isn't necessarily the best response to "no comments" but it's simplest and shouldn't happen
    let topMarginSize : CGFloat = 11
    let textPreviewHeight : CGFloat = 38
    var moreCommentsStringHeight : CGFloat = 30
    var sizeOfMarginBetweenMoreCommentsAndBox : CGFloat = 2
    let heightOfWriteCommentsBox : CGFloat = 33
    let lowMarginSize : CGFloat = 4
    
    if ((tableViewCell.isTextLongEnoughToBeTruncated && shouldTruncate) || (postData.comments.count == 0))
    {
        print("no visibility")
        changeCommentPreviewVisibility(tableViewCell: tableViewCell, constraintSizes: [0, 0, 0, 0, 0, 0])
    }
    else
    {
        print("with visibility")
        if (postData.comments.count < 2)
        {
            moreCommentsStringHeight = 0
            sizeOfMarginBetweenMoreCommentsAndBox = 1
        }
        changeCommentPreviewVisibility(
            tableViewCell: tableViewCell,
            constraintSizes: [topMarginSize, textPreviewHeight, moreCommentsStringHeight, sizeOfMarginBetweenMoreCommentsAndBox, heightOfWriteCommentsBox, lowMarginSize])
    }
}

func changeCommentPreviewVisibility(tableViewCell : SnippetTableViewCell, constraintSizes: [CGFloat])
{
    if (tableViewCell.topOfPreviewCommentsConstraint != nil)
    {
        tableViewCell.topOfPreviewCommentsConstraint.constant = constraintSizes[0]
    }
    if (tableViewCell.topOfMoreCommentsConstraint != nil)
    {
        tableViewCell.topOfMoreCommentsConstraint.constant = constraintSizes[3]
    }
    if (tableViewCell.bottomOfWriterBoxConstraint != nil)
    {
        tableViewCell.bottomOfWriterBoxConstraint.constant = constraintSizes[5]
    }
    
    for constraint in tableViewCell.singleCommentPreview.constraints
    {
        if constraint.identifier == "previewHeightConstraintTop"
        {
            constraint.constant = constraintSizes[1]
        }
    }
    for constraint in tableViewCell.moreCommentsPreview.constraints
    {
        if constraint.identifier == "previewHeightConstraintMiddle"
        {
            constraint.constant = constraintSizes[2]
        }
    }
    for constraint in tableViewCell.writeCommentBox.constraints
    {
        if constraint.identifier == "previewHeightConstraintBottom"
        {
            constraint.constant = constraintSizes[4]
        }
    }
}

func setStateOfHeightConstraint(view : UIView, identifier : String, state : Bool)
{
    for constraint in view.constraints
    {
        if constraint.identifier == identifier
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
