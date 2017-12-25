//
//  WebUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 12/5/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import Cache

class WebUtils
{
    static let shared = WebUtils()
    
    var csrfTokenValue : String = ""
    
    func runFunctionAfterGettingCsrfToken(functionData : Any, completionHandler: @escaping (_ handlerParams : Any, _ csrfToken : String) -> ())
    {
        if csrfTokenValue != ""
        {
            completionHandler(functionData, csrfTokenValue)
        }
        else
        {
            getCookiesFromServer(handlerParams: functionData, completionHandler: completionHandler)
        }
    }
    
    func getCookiesFromServer(handlerParams : Any, completionHandler: @escaping (_ handlerParams : Any, _ csrfToken : String) -> ())
    {
        let url : URL = URL(string: SystemVariables().URL_STRING)!
        
        let cookieStorage = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": "key=value"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
        cookieStorage.setCookies(cookies, for: url, mainDocumentURL: url)
        
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpShouldHandleCookies = true
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            if (response != nil)
            {
                let httpResponse = response as! HTTPURLResponse
                let responseHeaderFields = httpResponse.allHeaderFields as! [String : String]
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: responseHeaderFields, for: url)
                for cookie in cookies
                {
                    if cookie.name == "csrftoken"
                    {
                        self.csrfTokenValue = cookie.value
                    }
                }
                completionHandler(handlerParams, self.csrfTokenValue)
            }
            else
            {
                Logger().logInternetConnectionFailed()
            }
        }).resume()
    }
    
    func postContentWithJsonBody(jsonString : Dictionary<String,String>, urlString : String, csrfToken : String)
    {
        postContentWithJsonBody(jsonString: jsonString, urlString: urlString, csrfToken: csrfToken, completionHandler: nilFunction)
    }
    
    func postContentWithJsonBody(jsonString : Dictionary<String,String>, urlString : String, csrfToken : String, completionHandler : @escaping (_ responseString : String) -> ())
    {
        var urlRequest : URLRequest = getDefaultURLRequest(serverString: urlString, csrfValue: csrfToken)
        
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
