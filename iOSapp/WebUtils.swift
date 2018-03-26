//
//  WebUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 12/5/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import Cache

let TIME_STRING_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().PUBLISH_TIME_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().PUBLISH_TIME_COLOR]
let WRITER_STRING_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().PUBLISH_WRITER_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().PUBLISH_WRITER_COLOR]
let IMAGE_DESCRIPTION_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().IMAGE_DESCRIPTION_TEXT_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().IMAGE_DESCRIPTION_COLOR]

class WebUtils
{
    static let shared = WebUtils()
    
    var currentURLString : String = SystemVariables().URL_STRING
    
    func postContentWithJsonBody(jsonString : Dictionary<String,String>, urlString : String)
    {
        postContentWithJsonBody(jsonString: jsonString, urlString: urlString, completionHandler: nilFunction)
    }
    
    func postContentWithJsonBody(jsonString : Dictionary<String,String>, urlString : String, completionHandler : @escaping (_ responseString : String) -> ())
    {
        var urlRequest : URLRequest = getDefaultURLRequest(serverString: urlString, method: "POST")
        
        let commentData : Dictionary<String,String> = jsonString
        let jsonString = convertDictionaryToJsonString(dictionary: commentData)
        urlRequest.httpBody = jsonString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else
            {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")

            completionHandler(responseString!)
        }
        task.resume()
    }
    
    func nilFunction(responseString : String)
    {
        print("doing nothing")
    }
    
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
    
    func getImageFromWebSync(urlString : String) -> UIImage
    {
        let storage = AppCache.shared.getStorage()
        if let cachedImage = try? storage.object(ofType: ImageWrapper.self, forKey: urlString).image
        {
            return cachedImage
        }
        else
        {
            let url = NSURL(string:urlString)
            let data = NSData(contentsOf:url! as URL)
            if data != nil
            {
                return UIImage(data:data! as Data)!
            }
        }
        
        return UIImage()
    }
}
