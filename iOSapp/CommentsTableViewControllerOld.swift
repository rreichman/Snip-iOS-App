//
//  CommentsTableViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/26/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class CommentsTableViewControllerOld: UITableViewController
{
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    var heightAtIndexPath = NSMutableDictionary()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //tableView.rowHeight = UITableViewAutomaticDimension
        /*var commentsDataSource : CommentsDataSource = CommentsDataSource()
        var commentOne : Comment = Comment(commentData: ["body" : "body", "date" : "date", "id" : 123, "level" : 4, "parent" : 12, "user" : ["name" : "writer", "username" : "writerusername"]] as! [String : Any])
        commentsDataSource.commentDataArray.append(commentOne)*/
        //tableView.dataSource = commentsDataSource
        //tableView.dataSource = self
        //tableView.delegate = self
        print("loaded comments")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //print("entered count and it is \(commentDataArray.count)")
        //return commentDataArray.count
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print("entered cellForRowAt at row \(indexPath.row)")
        let commentCell : CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        //commentCell.singleCommentView.text = commentDataArray[indexPath.row].body
        commentCell.singleComment.text = "pizza pizza"
        return commentCell
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
