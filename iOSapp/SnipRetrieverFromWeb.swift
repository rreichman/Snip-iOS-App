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
    var feedDataSource = FeedDataSource()
    var lock : NSLock = NSLock()
    
    func clean()
    {
        areTherePostsRemainingOnServer = true
        WebUtils().csrfTokenValue = ""
        currentUrlString = SystemVariables().URL_STRING
        feedDataSource = FeedDataSource()
        lock.unlock()
    }
    
    func getSnipsJsonFromWebServer(completionHandler: @escaping (_ dataSource : FeedDataSource) -> ())
    {
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
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
            {
                self.loadDataFromWebIntoFeed(resultArray: jsonObj, completionHandler: completionHandler)
            }
        }).resume()
    }

    func getNextPage(next_page : Int) -> String
    {
        return SystemVariables().URL_STRING + "?page=" + String(next_page)
    }

    func loadDataFromWebIntoFeed(resultArray: [String : Any], completionHandler: @escaping (_ dataSource : FeedDataSource) -> ())
    {
        let postsAsJson : [[String : Any]] = resultArray["posts"] as! [[String : Any]]
        
        for postAsJson in postsAsJson
        {
            if !resultArray.keys.contains("next_page")
            {
                areTherePostsRemainingOnServer = false
            }
            else
            {
                currentUrlString = getNextPage(next_page: resultArray["next_page"] as! Int)
            }
            let newPost = PostData(receivedPostJson : postAsJson)
            
            feedDataSource.postDataArray.append(newPost)
        }
        
        completionHandler(feedDataSource)
    }
    
    func loadMorePosts(completionHandler: @escaping (_ dataSource : FeedDataSource) -> ())
    {
        print("loading more posts")
        if (lock.try())
        {
            getSnipsJsonFromWebServer(completionHandler: completionHandler)
        }
    }
}
