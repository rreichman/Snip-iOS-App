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
    var areTherePostsRemainingOnServer : Bool = true
    // This is not ideal but is a useful trick to avoid losing the feed's order in case of a bad external snippet
    var previousUrlString : String = SystemVariables().URL_STRING
    var currentUrlString : String = SystemVariables().URL_STRING
    
    // This is a not to pretty way to know if we're currently at the core view controller. TODO: change this
    var isCoreSnipViewController : Bool = false
    
    var lock : NSLock = NSLock()
    
    func setCurrentUrlString(urlString: String)
    {
        previousUrlString = currentUrlString
        currentUrlString = urlString
        
        if (isCoreSnipViewController)
        {
            WebUtils.shared.currentURLString = currentUrlString
        }
    }
    
    func clean()
    {
        clean(newUrlString: "")
    }
    
    func clean(newUrlString : String)
    {
        areTherePostsRemainingOnServer = true
        if (newUrlString == "")
        {
            setCurrentUrlString(urlString: SystemVariables().URL_STRING)
        }
        else
        {
            setCurrentUrlString(urlString: newUrlString)
        }
        lock.unlock()
    }
    
    func getSnipsJsonFromWebServer(completionHandler: @escaping (_ postDataArray : [PostData], _ appendDataAndNotReplace : Bool) -> (), appendDataAndNotReplace : Bool, errorHandler : (() -> Void)? = nil)
    {
        print("POSTS: getting posts. Current URL string: \(currentUrlString)")
        
        let urlRequest: URLRequest = getDefaultURLRequest(serverString: currentUrlString, method: "GET")
        
        if (!areTherePostsRemainingOnServer)
        {
            return
        }
        
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
                else
                {
                    print("unable to deserialize snippets")
                    if (errorHandler != nil)
                    {
                        Logger().logErrorInSnippetCollecting()
                        print("REVERTED to previous string!")
                        self.setCurrentUrlString(urlString: self.previousUrlString)
                        
                        errorHandler!()
                    }
                }
            }
            else
            {
                if (errorHandler != nil)
                {
                    print("got error in data request")
                    Logger().logErrorInSnippetCollecting()
                    self.setCurrentUrlString(urlString: SystemVariables().URL_STRING)
                    
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
        
        if !resultArray.keys.contains("next_page")
        {
            self.areTherePostsRemainingOnServer = false
        }
        else
        {
            self.setCurrentUrlString(urlString: self.getNextPage(next_page: resultArray["next_page"] as! Int))
        }
        
        for postAsJson in postsAsJson
        {
            taskGroup.enter()
            let newPost = PostData(receivedPostJson : postAsJson, taskGroup: taskGroup)
            postDataArray.append(newPost)
            count += 1
        }
        
        taskGroup.notify(queue: DispatchQueue.main)
        {
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
