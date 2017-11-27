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
    var comments : [Comment] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.rowHeight = 150
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        cell.singleComment.text = comments[indexPath.row].body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //return UITableViewAutomaticDimension
        return 150
    }
}
