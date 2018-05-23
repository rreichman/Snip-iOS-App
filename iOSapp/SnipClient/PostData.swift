//
//  PostData.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/29/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class PostData// : Encodable, Decodable
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
    var writerString : NSAttributedString = NSAttributedString()
    
    var attributedStringOfCommentCount = NSAttributedString()
    
    init() {}
    init (json: [String: Any]) {
        postJson = json
        loadRawJsonIntoVariables()
        self.textAfterHtmlRendering = NSMutableAttributedString(htmlString: self.text)!
        self.textAsAttributedStringWithTruncation = getAttributedTextOfCell(postData: self, widthOfTextArea: Float(getSnippetAreaWidth()), shouldTruncate: true)
        self.textAsAttributedStringWithoutTruncation = getAttributedTextOfCell(postData: self, widthOfTextArea: Float(getSnippetAreaWidth()), shouldTruncate: false)
        
        self.m_isTextLongEnoughToBeTruncated = isTextLongEnoughToBeTruncated(postData: self, widthOfTextArea: Float(getSnippetAreaWidth()))
        self.attributedStringOfCommentCount = getAttributedStringOfCommentCount(commentCount: self.comments.count)
        
        let updatedHtmlString = self.removePaddingFromHtmlString(str: self.image._imageDescription)
        
        let imageDescriptionString : NSMutableAttributedString = NSMutableAttributedString(htmlString : updatedHtmlString)!
        imageDescriptionString.addAttributes(IMAGE_DESCRIPTION_ATTRIBUTES, range: NSRange(location: 0,length: imageDescriptionString.length))
        self.imageDescriptionAfterHtmlRendering = imageDescriptionString
        
        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.alignment = .right
        
        self.imageDescriptionAfterHtmlRendering.addAttribute(NSAttributedStringKey.paragraphStyle, value: descriptionParagraphStyle, range: NSRange(location: 0, length: self.imageDescriptionAfterHtmlRendering.length))
        timeString = NSAttributedString(string: getTimeFromDateString(dateString: date), attributes: TIME_STRING_ATTRIBUTES)
        writerString = NSAttributedString(string: author._name, attributes: WRITER_STRING_ATTRIBUTES)
    }
    init(receivedPostJson : [String : Any], taskGroup: DispatchGroup)
    {        
        postJson = receivedPostJson
        loadRawJsonIntoVariables()
        
        DispatchQueue.global(qos: .default).async
        {
            self.textAfterHtmlRendering = NSMutableAttributedString(htmlString: self.text)!
            self.textAsAttributedStringWithTruncation = getAttributedTextOfCell(postData: self, widthOfTextArea: Float(getSnippetAreaWidth()), shouldTruncate: true)
            self.textAsAttributedStringWithoutTruncation = getAttributedTextOfCell(postData: self, widthOfTextArea: Float(getSnippetAreaWidth()), shouldTruncate: false)
            
            self.m_isTextLongEnoughToBeTruncated = isTextLongEnoughToBeTruncated(postData: self, widthOfTextArea: Float(getSnippetAreaWidth()))
            self.attributedStringOfCommentCount = getAttributedStringOfCommentCount(commentCount: self.comments.count)
            
            let updatedHtmlString = self.removePaddingFromHtmlString(str: self.image._imageDescription)
            
            let imageDescriptionString : NSMutableAttributedString = NSMutableAttributedString(htmlString : updatedHtmlString)!
            imageDescriptionString.addAttributes(IMAGE_DESCRIPTION_ATTRIBUTES, range: NSRange(location: 0,length: imageDescriptionString.length))
            self.imageDescriptionAfterHtmlRendering = imageDescriptionString
            
            let descriptionParagraphStyle = NSMutableParagraphStyle()
            descriptionParagraphStyle.alignment = .right
            
            self.imageDescriptionAfterHtmlRendering.addAttribute(NSAttributedStringKey.paragraphStyle, value: descriptionParagraphStyle, range: NSRange(location: 0, length: self.imageDescriptionAfterHtmlRendering.length))
            
            taskGroup.leave()
        }
        
        timeString = NSAttributedString(string: getTimeFromDateString(dateString: date), attributes: TIME_STRING_ATTRIBUTES)
        writerString = NSAttributedString(string: author._name, attributes: WRITER_STRING_ATTRIBUTES)
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
        
        if let voteJson = postJson["votes"] as? [String: Any] {
            if let l = voteJson["like"] as? Bool {
                isLiked = l
            } else { isLiked = false }
            if let d = voteJson["dislike"] as? Bool {
                isDisliked = d
            } else { isDisliked = false }
        } else {
            isLiked = false
            isDisliked = false
        }
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
    
    /*func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        try container.encode(postJson)
    }
    
    required init(from decoder: Decoder) throws
    {
        postJson = try decoder.singleValueContainer() as! [String : Any]
        loadRawJsonIntoVariables()
    }*/
}
