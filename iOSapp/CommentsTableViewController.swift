//
//  CommentsTableViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/26/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController
{
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    var heightAtIndexPath = NSMutableDictionary()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        /*var commentsDataSource : CommentsDataSource = CommentsDataSource()
        var commentOne : Comment = Comment(commentData: ["body" : "body", "date" : "date", "id" : 123, "level" : 4, "parent" : 12, "user" : ["name" : "writer", "username" : "writerusername"]] as! [String : Any])
        commentsDataSource.commentDataArray.append(commentOne)*/
        //tableView.dataSource = commentsDataSource
        //tableView.dataSource = self
        //tableView.delegate = self
        print("loaded comments")
    }
    
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
}
