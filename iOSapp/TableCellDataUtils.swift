//
//  CellTextUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

func fillImageDescription(snippetView : SnippetView, imageDescription : NSMutableAttributedString)
{
    snippetView.imageDescription.attributedText = imageDescription
    removePaddingFromTextView(textView: snippetView.imageDescription)
}

func setSnippetText(snippetView : SnippetView, postData : PostData, shouldTruncate : Bool)
{    
    if (shouldTruncate)
    {
        snippetView.body.attributedText = postData.textAsAttributedStringWithTruncation
    }
    else
    {
        snippetView.body.attributedText = postData.textAsAttributedStringWithoutTruncation
    }
    
    removePaddingFromTextView(textView: snippetView.body)
}

func setSnippetReferences(snippetView: SnippetView, postData : PostData, shouldTruncate : Bool, isTextLongEnoughToBeTruncated: Bool)
{
    if (isTextLongEnoughToBeTruncated && shouldTruncate)
    {
        snippetView.references.attributedText = NSAttributedString()
        snippetView.referencesTopConstraint.constant = 0
    }
    else
    {
        addReferencesStringsToSnippet(snippetView: snippetView, postData: postData)
        snippetView.referencesTopConstraint.constant = -5
    }
    
    setStateOfHeightConstraint(view: snippetView.references, identifier: "referencesHeightConstraint", state: isTextLongEnoughToBeTruncated && shouldTruncate)
}

func addReferencesStringsToSnippet(snippetView: SnippetView, postData: PostData)
{
    let allReferencesString = getReferencesStringFromPostData(postData: postData)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = SystemVariables().LINE_SPACING_IN_REFERENCES
    allReferencesString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: allReferencesString.length))
    allReferencesString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0,length: allReferencesString.length))
    
    snippetView.references.attributedText = allReferencesString
    snippetView.references.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : SystemVariables().REFERENCES_COLOR]
    removePaddingFromTextView(textView: snippetView.references)
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
