//
//  CommentDataSource.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/25/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class CommentsDataSource: NSObject, UITableViewDataSource
{
    var commentDataArray : [Comment] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("entered count and it is \(commentDataArray.count)")
        return commentDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print("entered cellForRowAt at row \(indexPath.row)")
        let commentCell : CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        //commentCell.singleCommentView.text = commentDataArray[indexPath.row].body
        commentCell.singleComment.text = "pizza pizza"
        return commentCell
    }
}
