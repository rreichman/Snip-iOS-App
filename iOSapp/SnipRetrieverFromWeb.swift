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
        
        print("before data request \(Date())")
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            print("at beginning of data request \(Date())")
            if (response != nil)
            {
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                {
                    print("after deserialization of data request \(Date())")
                    self.loadDataFromWebIntoFeed(resultArray: jsonObj, completionHandler: completionHandler, appendDataAndNotReplace : appendDataAndNotReplace)
                    print("after loading of data request \(Date())")
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
            print("at end of data request \(Date())")
        }).resume()
    }

    func getNextPage(next_page : Int) -> String
    {
        return SystemVariables().URL_STRING + "?page=" + String(next_page)
    }

    func loadDataFromWebIntoFeed(resultArray: [String : Any], completionHandler: @escaping (_ postDataArray : [PostData], _ appendDataAndNotReplace : Bool) -> (), appendDataAndNotReplace : Bool)
    {
        print("about to load web data into feed. \(Date())")
        let postsAsJson : [[String : Any]] = resultArray["posts"] as! [[String : Any]]
        var postDataArray : [PostData] = []
        var count = 0
        
        let taskGroup = DispatchGroup()

        for postAsJson in postsAsJson
        {
            taskGroup.enter()
            
            if !resultArray.keys.contains("next_page")
            {
                self.areTherePostsRemainingOnServer = false
            }
            else
            {
                self.currentUrlString = self.getNextPage(next_page: resultArray["next_page"] as! Int)
            }
            
            let newPost = PostData(receivedPostJson : postAsJson, taskGroup: taskGroup)
            postDataArray.append(newPost)
            
            count += 1
        }
        
        print("waiting for posts. \(Date())")
        
        taskGroup.notify(queue: DispatchQueue.main)
        {
            print("done loading web data into feed. \(Date())")
            completionHandler(postDataArray, appendDataAndNotReplace)
        }
    }
    
    func loadMorePosts(completionHandler: @escaping (_ postDataArray : [PostData], _ appendDataAndNotReplace : Bool) -> ())
    {
        if (lock.try())
        {
            getSnipsJsonFromWebServer(completionHandler: completionHandler, appendDataAndNotReplace: true)
        }
    }
}
