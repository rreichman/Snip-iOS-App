//
//  CellTextUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 2/1/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

func isTextLongEnoughToBeTruncated(postData : PostData, widthOfTextArea : Float) -> Bool
{
    return postData.textAfterHtmlRendering.length >= getMaxLengthToTruncate(widthOfTextArea: widthOfTextArea)
}

func getPreviewSize(widthOfTextArea : Float) -> Int
{
    let widthOfSingleChar = getWidthOfSingleChar(font : SystemVariables().CELL_TEXT_FONT!)
    // Note - perhaps it would have been better to use the width of the table cell but that number subtly changes sometimes, creating annoying inconsistencies
    let sizeOfRowInChars = widthOfTextArea / widthOfSingleChar
    return Int(floor(Float(sizeOfRowInChars) * Float(SystemVariables().NUMBER_OF_ROWS_IN_PREVIEW))) - SystemVariables().READ_MORE_TEXT.count
}

func getMaxLengthToTruncate(widthOfTextArea : Float) -> Int
{
    // Note - perhaps it would have been better to use the width of the table cell but that number subtly changes sometimes, creating annoying inconsistencies
    let widthOfSingleChar = getWidthOfSingleChar(font : SystemVariables().CELL_TEXT_FONT!)
    let sizeOfRowInChars = widthOfTextArea / widthOfSingleChar
    
    return Int(floor(Float(sizeOfRowInChars) * Float(SystemVariables().NUMBER_OF_ROWS_TO_TRUNCATE)))
}

func getAttributedTextOfCell(postData : PostData, widthOfTextArea : Float, shouldTruncate : Bool) -> NSMutableAttributedString
{
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.hyphenationFactor = 1.0
    paragraphStyle.lineSpacing = SystemVariables().LINE_SPACING_IN_TEXT
    paragraphStyle.paragraphSpacing = 7.0
    
    let text : NSMutableAttributedString = getAttributedTextAfterPossibleTruncation(postData : postData, widthOfTextArea: widthOfTextArea, shouldTruncate : shouldTruncate)
    
    if (isTextLongEnoughToBeTruncated(postData: postData, widthOfTextArea: widthOfTextArea) && shouldTruncate)
    {
        let READ_MORE_ATTRIBUTED_STRING = NSAttributedString(string: SystemVariables().READ_MORE_TEXT,
                                                             attributes : [NSAttributedStringKey.foregroundColor: SystemVariables().READ_MORE_TEXT_COLOR, NSAttributedStringKey.font : SystemVariables().READ_MORE_TEXT_FONT!])
        text.append(READ_MORE_ATTRIBUTED_STRING)
    }
    text.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: text.length))
    
    return text
}

func getAttributedTextAfterPossibleTruncation(postData : PostData, widthOfTextArea : Float, shouldTruncate : Bool) -> NSMutableAttributedString
{
    let text = postData.textAfterHtmlRendering
    var updatedText : NSMutableAttributedString = text
    if (text.length >= getMaxLengthToTruncate(widthOfTextArea: widthOfTextArea) && shouldTruncate)
    {
        updatedText = text.attributedSubstring(from: NSRange(location: 0, length: getPreviewSize(widthOfTextArea: widthOfTextArea))).mutableCopy() as! NSMutableAttributedString
    }
    
    let stringAttributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().CELL_TEXT_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().CELL_TEXT_COLOR]
    updatedText.addAttributes(stringAttributes, range: NSRange(location: 0, length: updatedText.length))
    return updatedText
}
