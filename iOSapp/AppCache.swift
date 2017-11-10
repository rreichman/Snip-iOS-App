//
//  AppCache.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/30/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import Cache

// This is implemented with a Singleton since there's only one cache
final class AppCache
{
    static let shared = AppCache()
    
    var diskConfig : DiskConfig
    var memoryConfig : MemoryConfig
    var storage : Storage
    
    private init()
    {
        diskConfig = DiskConfig(name: "Floppy")
        memoryConfig = MemoryConfig(expiry: .never, countLimit: 20, totalCostLimit: 0)
        storage = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
    }
    
    func getStorage() -> Storage
    {
        return storage
    }
    
    func insertPostDataIntoCache(postData : PostData)
    {
        do
        {
            try storage.setObject(postData, forKey: String(postData._id))
        }
        catch
        {
            print("error inserting post data into cache")
        }
    }
    
    func getPostDataFromCache(id : Int) -> PostData
    {
        do
        {
            let postData : PostData = try storage.object(ofType: PostData.self, forKey: String(id))
            return postData
        }
        catch
        {
            return PostData()
        }
    }
}
