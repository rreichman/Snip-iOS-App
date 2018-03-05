//
//  CellTextUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

let referenceAttributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().REFERENCES_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().REFERENCES_COLOR]
let headlineAttributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().HEADLINE_TEXT_FONT, NSAttributedStringKey.foregroundColor : SystemVariables().HEADLINE_TEXT_COLOR]

func setSnippetHeadline(snippetView : SnippetView, postData: PostData)
{
    let headlineParagraphStyle = NSMutableParagraphStyle()
    headlineParagraphStyle.lineSpacing = SystemVariables().LINE_SPACING_IN_HEADLINE
    
    let headlineString = NSMutableAttributedString(string: postData.headline, attributes: headlineAttributes)
    headlineString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: headlineString.length))
    
    snippetView.headline.attributedText = headlineString
}

func fillImageDescription(snippetView : SnippetView, imageDescription : NSMutableAttributedString)
{
    snippetView.imageDescription.attributedText = imageDescription
    removePaddingFromTextView(textView: snippetView.imageDescription)
}

func setSnippetText(snippetView : SnippetView, postData : PostData, shouldTruncate : Bool)
{    
    if (shouldTruncate)
    {
        snippetView.body.attributedText = snippetView.truncatedBody
    }
    else
    {
        snippetView.body.attributedText = snippetView.nonTruncatedBody
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
        snippetView.referencesTopConstraint.constant = -15
    }
    
    setStateOfHeightConstraint(view: snippetView.references, identifier: "referencesHeightConstraint", state: isTextLongEnoughToBeTruncated && shouldTruncate)
}

func addReferencesStringsToSnippet(snippetView: SnippetView, postData: PostData)
{
    let allReferencesString = getReferencesStringFromPostData(postData: postData)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = SystemVariables().LINE_SPACING_IN_REFERENCES
    allReferencesString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: allReferencesString.length))
    
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
    let referencesString = NSMutableAttributedString()
    var count = 1
    
    let commaSeparatorString = NSAttributedString(string : ", ", attributes: referenceAttributes)
    
    for reference in postData.relatedLinks
    {
        let title : String = reference["title"] as! String
        let referenceString = NSMutableAttributedString(string: title, attributes: referenceAttributes)
        referenceString.addAttribute(.link, value: reference["link"]!, range: NSRange(location:0, length: title.count))
        referenceString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0,length: referenceString.length))
        
        referencesString.append(referenceString)
        
        if count < postData.relatedLinks.count
        {
            referencesString.append(commaSeparatorString)
        }
        
        count += 1
    }
    return referencesString
}
