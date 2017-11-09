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
    
    public func imageFromServerURL(urlString: String) throws -> Error
    {
        // I don't want it taking the data from a previous image.
        self.image = nil
        
        let storage = AppCache.shared.getStorage()
        if let cachedImage = try? storage.object(ofType: ImageWrapper.self, forKey: urlString).image
        {
            //print("using cache with image " + urlString)
            self.image = cachedImage
            return NoError()
        }

        if !isUrlValid(urlString: urlString)
        {
            throw ProgramError(errorMessage: "Invalid URL")
        }
        let url = NSURL(string: urlString)! as URL
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            print("inside async land")
            if error != nil
            {
                print("error in loading URL")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                // Cache to image so it doesn't need to be reloaded every time the user scrolls and table cells are re-used.
                if let image = UIImage(data: data!)
                {
                    let wrapper = ImageWrapper(image : image)
                    try? storage.setObject(wrapper, forKey: urlString)
                    self.image = image
                }
            })
            
        }).resume()
        return NoError()
    }
}
