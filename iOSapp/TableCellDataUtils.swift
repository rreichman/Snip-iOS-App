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
    cell.snippetView.imageDescription.attributedText = imageDescription
    removePaddingFromTextView(textView: cell.snippetView.imageDescription)
}

func setCellText(tableViewCell : SnippetTableViewCell, postData : PostData, shouldTruncate : Bool)
{    
    tableViewCell.m_isTextLongEnoughToBeTruncated = postData.m_isTextLongEnoughToBeTruncated
    
    if (shouldTruncate)
    {
        tableViewCell.snippetView.body.attributedText = postData.textAsAttributedStringWithTruncation
    }
    else
    {
        tableViewCell.snippetView.body.attributedText = postData.textAsAttributedStringWithoutTruncation
    }
    
    let isTextCurrentlyTruncated : Bool = tableViewCell.m_isTextLongEnoughToBeTruncated && shouldTruncate
    
    removePaddingFromTextView(textView: tableViewCell.snippetView.body)
}

func fillPublishTimeAndWriterInfo(cell : SnippetTableViewCell, timeAndWriterAttributedString : NSAttributedString)
{
    removePaddingFromTextView(textView: cell.snippetView.postTimeAndWriter)
    cell.snippetView.postTimeAndWriter.attributedText = timeAndWriterAttributedString
}

func setCellReferences(tableViewCell : SnippetTableViewCell, postData : PostData, shouldTruncate : Bool)
{
    if (tableViewCell.m_isTextLongEnoughToBeTruncated && shouldTruncate)
    {
        tableViewCell.snippetView.references.attributedText = NSAttributedString()
    }
    else
    {
        addReferencesStringsToCell(cell : tableViewCell, postData: postData)
    }
    
    setStateOfHeightConstraint(view: tableViewCell.snippetView.references, identifier: "referencesHeightConstraint", state: tableViewCell.m_isTextLongEnoughToBeTruncated && shouldTruncate)
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
    
    cell.snippetView.references.attributedText = allReferencesString
    cell.snippetView.references.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : SystemVariables().REFERENCES_COLOR]
    removePaddingFromTextView(textView: cell.snippetView.references)
}
