//
//  SnipImage.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/26/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

public class SnipImage
{
    var _imageURL : String = ""
    var _imageDescription : String = ""
    private var _imageData : UIImage = UIImage()
    var _gotImageData : Bool = false
    var _imageHeight : CGFloat = 100
    
    init()
    {
    }
    
    init(imageURL : String, imageDescription: String)
    {
        _imageURL = imageURL
        _imageDescription = imageDescription
    }
    
    init(imageData : [String : Any])
    {
        _imageURL = imageData["url"] as! String
        _imageDescription = imageData["description"] as! String
    }
    
    func setImageData(imageData: UIImage)
    {
        _imageData = imageData
        let ratio = imageData.size.width / getSnippetAreaWidth()
        _imageHeight = imageData.size.height / ratio
        _gotImageData = true
    }
    
    func getImageData() -> UIImage
    {
        return _imageData
    }
}
