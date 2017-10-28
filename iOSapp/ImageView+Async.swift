//
//  SnipImageView.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/27/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

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
        /*
        // First check if there is an image in the cache
        if let cachedImage = imageCache.object(forKey: urlString as NSString)
        {
            self.image = cachedImage   
            return
        }*/
        print("before async land")

        print("url string is " + urlString)
        if !isUrlValid(urlString: urlString)
        {
            print("nil URL")
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
                    //imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                }
            })
            
        }).resume()
        return NoError()
    }
}
