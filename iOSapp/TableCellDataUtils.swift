//
//  CellTextUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

func fillImageDescription(cell : SnippetTableViewCell, imageDescription : NSMutableAttributedString)
{
    cell.imageDescription.attributedText = imageDescription
    removePaddingFromTextView(textView: cell.imageDescription)
}

func setCellText(tableViewCell : SnippetTableViewCell, postData : PostData, shouldTruncate : Bool)
{    
    tableViewCell.m_isTextLongEnoughToBeTruncated = postData.m_isTextLongEnoughToBeTruncated
    
    if (shouldTruncate)
    {
        tableViewCell.body.attributedText = postData.textAsAttributedStringWithTruncation
    }
    else
    {
        tableViewCell.body.attributedText = postData.textAsAttributedStringWithoutTruncation
    }
    
    let isTextCurrentlyTruncated : Bool = tableViewCell.m_isTextLongEnoughToBeTruncated && shouldTruncate
    
    removePaddingFromTextView(textView: tableViewCell.body)
}

func fillPublishTimeAndWriterInfo(cell : SnippetTableViewCell, timeAndWriterAttributedString : NSAttributedString)
{
    removePaddingFromTextView(textView: cell.postTimeAndWriter)
    cell.postTimeAndWriter.attributedText = timeAndWriterAttributedString
}

func setCellReferences(tableViewCell : SnippetTableViewCell, postData : PostData, shouldTruncate : Bool)
{
    if (tableViewCell.m_isTextLongEnoughToBeTruncated && shouldTruncate)
    {
        tableViewCell.references.attributedText = NSAttributedString()
    }
    else
    {
        addReferencesStringsToCell(cell : tableViewCell, postData: postData)
    }
    
    setStateOfHeightConstraint(view: tableViewCell.references, identifier: "referencesHeightConstraint", state: tableViewCell.m_isTextLongEnoughToBeTruncated && shouldTruncate)
}

func setCellCommentPreview(tableViewCell: SnippetTableViewCell, postData: PostData, shouldTruncate: Bool)
{
    let isShowingPreview = !((tableViewCell.m_isTextLongEnoughToBeTruncated && shouldTruncate) || (postData.comments.count == 0))
    
    if (isShowingPreview)
    {
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
        previewString.addAttributes([NSAttributedStringKey.font : SystemVariables().COMMENT_PREVIEW_TEXT_FONT], range: NSRange(location: firstCommentWriter.count, length: previewString.length - firstCommentWriter.count))
        
        tableViewCell.singleCommentPreview.attributedText = previewString
        
        let moreCommentsFullString = getMoreCommentsFullString(postData: postData)
        
        let moreCommentsAttributedString : NSMutableAttributedString = NSMutableAttributedString(string: moreCommentsFullString)
        moreCommentsAttributedString.setAttributes([NSAttributedStringKey.foregroundColor : UIColor.gray], range: NSRange(location: 0,length: moreCommentsAttributedString.length))
        
        tableViewCell.moreCommentsPreview.attributedText = moreCommentsAttributedString
    }
    
    setVisibilityForCommentPreview(tableViewCell: tableViewCell, postData: postData, shouldTruncate: shouldTruncate, isShowingPreview: isShowingPreview)
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

func setVisibilityForCommentPreview(tableViewCell: SnippetTableViewCell, postData: PostData, shouldTruncate: Bool, isShowingPreview : Bool)
{
    // Note - This (no preview) isn't necessarily the best response to "no comments" but it's simplest and shouldn't happen
    let topMarginSize : CGFloat = 11
    let textPreviewHeight : CGFloat = 38
    var moreCommentsStringHeight : CGFloat = 30
    var sizeOfMarginBetweenMoreCommentsAndBox : CGFloat = 2
    let heightOfWriteCommentsBox : CGFloat = 33
    let lowMarginSize : CGFloat = 4
    
    if (!isShowingPreview)
    {
        changeCommentPreviewVisibility(tableViewCell: tableViewCell, constraintSizes: [0, 0, 0, 0, 0, 0])
    }
    else
    {
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
    allReferencesString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0,length: allReferencesString.length))
    
    cell.references.attributedText = allReferencesString
    cell.references.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : SystemVariables().REFERENCES_COLOR]
    removePaddingFromTextView(textView: cell.references)
}
