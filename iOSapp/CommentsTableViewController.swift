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
    var commentsInNestedFormat : [Comment] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        var currentComment : Comment = commentsInNestedFormat[indexPath.row]
        cell.body.text = currentComment.body
        cell.date.text = getTimeFromDateString(dateString: currentComment.date)
        cell.writer.text = currentComment.writer._name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return commentsInNestedFormat.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
}
