//
//  SnipRetriever.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class SnipRetrieverFromWeb
{
    static let shared = SnipRetrieverFromWeb()
    
    var areTherePostsRemainingOnServer : Bool = true
    var currentUrlString : String = SystemVariables().URL_STRING
    var lock : NSLock = NSLock()
    
    func clean()
    {
        areTherePostsRemainingOnServer = true
        WebUtils().csrfTokenValue = ""
        currentUrlString = SystemVariables().URL_STRING
        lock.unlock()
    }
    
    func getSnipsJsonFromWebServer(completionHandler: @escaping (_ postDataArray : [PostData], _ appendDataAndNotReplace : Bool) -> (), appendDataAndNotReplace : Bool, errorHandler : (() -> Void)? = nil)
    {
        print("getting posts. Current URL string: \(currentUrlString)")
        let url: URL = URL(string: currentUrlString)!
        var urlRequest: URLRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if (!areTherePostsRemainingOnServer)
        {
            return
        }
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            if (response != nil)
            {
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                {
                    self.loadDataFromWebIntoFeed(resultArray: jsonObj, completionHandler: completionHandler, appendDataAndNotReplace : appendDataAndNotReplace)
                }
            }
            else
            {
                if (errorHandler != nil)
                {
                    Logger().logErrorInSnippetCollecting()
                    errorHandler!()
                }
            }
        }).resume()
    }

    func getNextPage(next_page : Int) -> String
    {
        return SystemVariables().URL_STRING + "?page=" + String(next_page)
    }

    func loadDataFromWebIntoFeed(resultArray: [String : Any], completionHandler: @escaping (_ postDataArray : [PostData], _ appendDataAndNotReplace : Bool) -> (), appendDataAndNotReplace : Bool)
    {
        let postsAsJson : [[String : Any]] = resultArray["posts"] as! [[String : Any]]
        var postDataArray : [PostData] = []
        
        for postAsJson in postsAsJson
        {
            if !resultArray.keys.contains("next_page")
            {
                areTherePostsRemainingOnServer = false
            }
            else
            {
                print(currentUrlString)
                currentUrlString = getNextPage(next_page: resultArray["next_page"] as! Int)
            }
            let newPost = PostData(receivedPostJson : postAsJson)
            postDataArray.append(newPost)
        }
        
        completionHandler(postDataArray, appendDataAndNotReplace)
    }
    
    func loadMorePosts(completionHandler: @escaping (_ postDataArray : [PostData], _ appendDataAndNotReplace : Bool) -> ())
    {
        if (lock.try())
        {
            getSnipsJsonFromWebServer(completionHandler: completionHandler, appendDataAndNotReplace: true)
        }
    }
}
