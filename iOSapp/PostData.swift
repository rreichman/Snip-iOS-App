//
//  PostData.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/29/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class PostData : Encodable, Decodable
{
    var postJson : [String : Any] = [:]
    var id : Int = 0
    var author : SnipUser = SnipUser()
    var headline : String = ""
    var text : String = ""
    // Perhaps store the date as something else in the future (not sure)
    var date : String = ""
    var image : SnipImage = SnipImage()
    var relatedLinks : [[String : Any]] = []
    var isLiked : Bool = false
    var isDisliked : Bool = false
    var comments : [Comment] = []
    var fullURL : String = ""
    
    var m_isTextLongEnoughToBeTruncated : Bool = true
    
    // These two variables save resources when scrolling
    var textAsAttributedStringWithTruncation : NSAttributedString = NSAttributedString()
    var textAsAttributedStringWithoutTruncation : NSAttributedString = NSAttributedString()
    
    var isFirstTime = true
    
    // These two variables save resources when scrolling
    var imageDescriptionAfterHtmlRendering : NSMutableAttributedString = NSMutableAttributedString()
    var textAfterHtmlRendering : NSMutableAttributedString = NSMutableAttributedString()
    
    var timeString : NSAttributedString = NSAttributedString()
    let TIME_STRING_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().PUBLISH_TIME_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().PUBLISH_TIME_COLOR]
    var writerString : NSAttributedString = NSAttributedString()
    let WRITER_STRING_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().PUBLISH_WRITER_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().PUBLISH_WRITER_COLOR]
    
    init() {}
    
    init(receivedPostJson : [String : Any])
    {
        postJson = receivedPostJson
        loadRawJsonIntoVariables()
        
        // This is an optimization to make loading look better.
        if (isFirstTime)
        {
            self.textAfterHtmlRendering = NSMutableAttributedString(htmlString: self.text)!
            isFirstTime = false
        }
        else
        {
            DispatchQueue.main.async
            {
                self.textAfterHtmlRendering = NSMutableAttributedString(htmlString: self.text)!
            }
        }
        
        DispatchQueue.main.async
        {
            let imageDescriptionAttributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().IMAGE_DESCRIPTION_TEXT_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().IMAGE_DESCRIPTION_COLOR]
            let updatedHtmlString = self.removePaddingFromHtmlString(str: self.image._imageDescription)
            let imageDescriptionString : NSMutableAttributedString = NSMutableAttributedString(htmlString : updatedHtmlString)!
            imageDescriptionString.addAttributes(imageDescriptionAttributes, range: NSRange(location: 0,length: imageDescriptionString.length))
            self.imageDescriptionAfterHtmlRendering = imageDescriptionString
            
            let descriptionParagraphStyle = NSMutableParagraphStyle()
            descriptionParagraphStyle.alignment = .right
            
            self.imageDescriptionAfterHtmlRendering.addAttribute(NSAttributedStringKey.paragraphStyle, value: descriptionParagraphStyle, range: NSRange(location: 0, length: self.imageDescriptionAfterHtmlRendering.length))
        }
        
        textAsAttributedStringWithTruncation = getAttributedTextOfCell(postData: self, widthOfTextArea: getSnippetTextAreaWidth(), shouldTruncate: true)
        textAsAttributedStringWithoutTruncation = getAttributedTextOfCell(postData: self, widthOfTextArea: getSnippetTextAreaWidth(), shouldTruncate: false)
        
        timeString = NSAttributedString(string: getTimeFromDateString(dateString: date), attributes: TIME_STRING_ATTRIBUTES)
        writerString = NSAttributedString(string: author._name, attributes: WRITER_STRING_ATTRIBUTES)
        
        m_isTextLongEnoughToBeTruncated = isTextLongEnoughToBeTruncated(postData: self, widthOfTextArea: getSnippetTextAreaWidth())
    }
    
    func getSnippetTextAreaWidth() -> Float
    {
        // TODO: this is not ideal
        let sizeOfLeftBorder = 20
        let sizeOfRightBorder = 20

        return Float(Int(CachedData().getScreenWidth()) - sizeOfLeftBorder - sizeOfRightBorder)
    }
    
    func removePaddingFromHtmlString(str: String) -> String
    {
        var newStr = str.replacingOccurrences(of: "<p>", with: "")
        newStr = newStr.replacingOccurrences(of: "</p>", with: "")
        return newStr
    }
    
    func setImageIfExists(postJson : [String : Any])
    {
        if postJson["image"] != nil
        {
            if !(postJson["image"] is NSNull)
            {
                image = SnipImage(imageData: postJson["image"] as! [String : Any])
            }
        }
    }
   
    func loadRawJsonIntoVariables()
    {
        id = postJson["id"] as! Int
        if (postJson["author"] == nil)
        {
            author = SnipUser(userData: ["name" : "authorName", "username": "authorUsername"])
        }
        else
        {
            author = SnipUser(userData: postJson["author"] as! [String : Any])
        }
        headline = postJson["title"] as! String
        text = postJson["body"] as! String
        date = postJson["date"] as! String
        setImageIfExists(postJson: postJson)
        relatedLinks = postJson["related_links"] as! [[String : Any]]
        isLiked = (postJson["votes"] as! [String : Bool])["like"]!
        isDisliked = (postJson["votes"] as! [String : Bool])["dislike"]!
        fullURL = postJson["url"] as! String
        comments = convertJsonArrayIntoCommentArray(commentArrayData: postJson["comments"] as! [[String : Any]])
    }
    
    func convertJsonArrayIntoCommentArray(commentArrayData : [[String : Any]]) -> [Comment]
    {
        var comments : [Comment] = []
        
        for commentData in commentArrayData
        {
            comments.append(Comment(commentData: commentData))
        }
        
        return comments
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        try container.encode(postJson)
    }
    
    required init(from decoder: Decoder) throws
    {
        postJson = try decoder.singleValueContainer() as! [String : Any]
        loadRawJsonIntoVariables()
    }
}
