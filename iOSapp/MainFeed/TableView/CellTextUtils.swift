//
//  CellTextUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 2/1/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

// Note - perhaps it would have been better to use the width of the table cell but that number subtly changes sometimes, creating annoying inconsistencies
let widthOfSingleChar = getWidthOfSingleChar(font : SystemVariables().CELL_TEXT_FONT!)

let READ_MORE_ATTRIBUTED_STRING = NSAttributedString(string: SystemVariables().READ_MORE_TEXT,
                                                     attributes : [NSAttributedStringKey.foregroundColor: SystemVariables().READ_MORE_TEXT_COLOR, NSAttributedStringKey.font : SystemVariables().READ_MORE_TEXT_FONT!])

let paragraphStyle = CachedData().getParagraphStyle()

let stringAttributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().CELL_TEXT_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().CELL_TEXT_COLOR]

// Above this number of rows we want to truncate the snippet because it's too long
let NUMBER_OF_ROWS_TO_TRUNCATE : Float = Float(6)
let NUMBER_OF_ROWS_IN_PREVIEW : Float = Float(2)

// This is not ideal but more efficient
let READ_MORE_TEXT_LENGTH = SystemVariables().READ_MORE_TEXT.count

func isTextLongEnoughToBeTruncated(postData : PostData, widthOfTextArea : Float) -> Bool
{
    let textLength = postData.textAfterHtmlRendering.length
    let maxLengthToTruncate = getMaxLengthToTruncate(widthOfTextArea: widthOfTextArea)
    
    return textLength > maxLengthToTruncate
}

func getPreviewSize(widthOfTextArea : Float) -> Int
{
    let sizeOfRowInChars = widthOfTextArea / widthOfSingleChar
    return Int(floor(Float(sizeOfRowInChars) * NUMBER_OF_ROWS_IN_PREVIEW)) - READ_MORE_TEXT_LENGTH
}

func getMaxLengthToTruncate(widthOfTextArea : Float) -> Int
{
    let sizeOfRowInChars = widthOfTextArea / widthOfSingleChar
    return Int(floor(Float(sizeOfRowInChars) * NUMBER_OF_ROWS_TO_TRUNCATE))
}

func getAttributedTextOfCell(postData : PostData, widthOfTextArea : Float, shouldTruncate : Bool) -> NSMutableAttributedString
{
    let text : NSMutableAttributedString = getAttributedTextAfterPossibleTruncation(postData : postData, widthOfTextArea: widthOfTextArea, shouldTruncate : shouldTruncate)
    
    if (isTextLongEnoughToBeTruncated(postData: postData, widthOfTextArea: widthOfTextArea) && shouldTruncate)
    {
        text.append(READ_MORE_ATTRIBUTED_STRING)
    }
    
    text.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: text.length))
    
    return text
}

func getAttributedTextAfterPossibleTruncation(postData : PostData, widthOfTextArea : Float, shouldTruncate : Bool) -> NSMutableAttributedString
{
    let text = postData.textAfterHtmlRendering
    
    var updatedText : NSMutableAttributedString = text
    
    let maxLengthToTruncate = getMaxLengthToTruncate(widthOfTextArea: widthOfTextArea)
    
    if (text.length >= maxLengthToTruncate && shouldTruncate)
    {
        updatedText = text.attributedSubstring(from: NSRange(location: 0, length: getPreviewSize(widthOfTextArea: widthOfTextArea))).mutableCopy() as! NSMutableAttributedString
    }
    
    updatedText.addAttributes(stringAttributes, range: NSRange(location: 0, length: updatedText.length))
    
    return updatedText
}
