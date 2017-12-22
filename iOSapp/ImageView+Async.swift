//
//  SnipImageView.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/27/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
// This is from the Cache pod. Documentation here: https://github.com/hyperoslo/Cache
import Cache

extension UIImageView
{
    func isUrlValid(urlString: String?) -> Bool
    {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func imageFromServerURL(cell : SnippetTableViewCell, urlString: String) throws -> Error
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
                    print("here")
                    let wrapper = ImageWrapper(image : image)
                    try? storage.setObject(wrapper, forKey: urlString)
                    self.image = image
                    
                    print("Headline: \(cell.headline.text)")
                    print("Image width: \(image.size.width)")
                    print("Image height: \(image.size.height)")
                    print("Screen width: \(CachedData().getScreenWidth())")
                    let ratio = image.size.width / CachedData().getScreenWidth()
                    let newHeight = image.size.height / ratio
                    cell.imageNecessaryHeight = newHeight
                }
            })
            
        }).resume()
        return NoError()
    }
}
