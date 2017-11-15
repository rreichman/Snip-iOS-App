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
    
    var currentUrlString = SystemVariables().URL_STRING
    let feedDataSource = FeedDataSource()
    
    func getSnipsJsonFromWebServer(completionHandler: @escaping (_ dataSource : FeedDataSource) -> ())
    {
        let url: URL = URL(string: currentUrlString)!
        var urlRequest: URLRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
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
            currentUrlString = getNextPage(next_page: resultArray["next_page"] as! Int)
            let newPost = PostData(receivedPostJson : postAsJson)
            // TODO:: add caching later
            //let appCache = AppCache.shared
            
            feedDataSource.postDataArray.append(newPost)
        }
        
        completionHandler(feedDataSource)
    }
    
    func loadMorePosts(completionHandler: @escaping (_ dataSource : FeedDataSource) -> ())
    {
        getSnipsJsonFromWebServer(completionHandler: completionHandler)
    }
}
