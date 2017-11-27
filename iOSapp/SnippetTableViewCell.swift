//
//  MealTableViewCell.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/24/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class SnippetTableViewCell: UITableViewCell
{
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var imageDescription: UITextView!
    @IBOutlet weak var postTimeAndWriter: UITextView!
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var references: UITextView!
    @IBOutlet weak var likeButton: UIImageViewWithMetadata!
    @IBOutlet weak var dislikeButton: UIImageViewWithMetadata!
    @IBOutlet weak var commentButton: UIImageView!
    
    var isTextLongEnoughToBeTruncated : Bool = true
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        likeButton.unclickedImage = #imageLiteral(resourceName: "thumbsUp")
        likeButton.clickedImage = #imageLiteral(resourceName: "thumbsUpClicked")
        dislikeButton.unclickedImage = #imageLiteral(resourceName: "thumbsDown")
        dislikeButton.clickedImage = #imageLiteral(resourceName: "thumbsDownClicked")
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
