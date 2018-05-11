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
    //var previousUrlString : String = SystemVariables().URL_STRING + "old/"
    var baseURLString : String = SystemVariables().URL_STRING + "old/"
    var urlQuery : String = ""
    var urlNextPage : Int = 0
    
    // This is a not to pretty way to know if we're currently at the core view controller. TODO: change this
    var isCoreSnipViewController : Bool = false
    
    var lock : NSLock = NSLock()
    
    func getFullURLString() -> String
    {
        var fullURLString = baseURLString
        fullURLString += urlQuery
        
        if urlNextPage > 0
        {
            if urlQuery.count > 0
            {
                fullURLString += "&page=" + String(urlNextPage)
            }
            else
            {
                fullURLString += "?page=" + String(urlNextPage)
            }
        }
        
        return fullURLString
    }
    
    func setFullUrlString(urlString: String, query: String)
    {
        baseURLString = urlString
        urlQuery = query
        
        if (isCoreSnipViewController)
        {
            WebUtils.shared.currentURLString = getFullURLString()
        }
    }
    
    func clean()
    {
        clean(newUrlString: "", newQuery: "")
    }
    
    func clean(newUrlString : String, newQuery: String)
    {
        urlNextPage = 0
        areTherePostsRemainingOnServer = true
        if (newUrlString == "")
        {
            setFullUrlString(urlString: SystemVariables().URL_STRING, query: "")
        }
        else
        {
            setFullUrlString(urlString: newUrlString, query: newQuery)
        }
        lock.unlock()
    }
    
    func getSnipsJsonFromWebServer(completionHandler: @escaping (_ postDataArray : [PostData], _ appendDataAndNotReplace : Bool) -> (), appendDataAndNotReplace : Bool, errorHandler : (() -> Void)? = nil)
    {
        print("POSTS: getting posts. Current URL string: \(getFullURLString())")
        
        let urlRequest: URLRequest = getDefaultURLRequest(serverString: getFullURLString(), method: "GET")
        
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
                        self.clean()
                        
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
                    self.setFullUrlString(urlString: SystemVariables().URL_STRING, query: "")
                    
                    errorHandler!()
                }
            }
            print("at end of data request \(Date())")
        }).resume()
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
            urlNextPage = resultArray["next_page"] as! Int
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
