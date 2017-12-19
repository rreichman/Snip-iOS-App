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
    
    @IBOutlet weak var commentPreviewView: UIView!
    @IBOutlet weak var singleCommentPreview: UITextView!
    @IBOutlet weak var moreCommentsPreview: UITextView!
    
    @IBOutlet weak var writeCommentBox: UITextView!
    
    @IBOutlet weak var topOfPreviewCommentsConstraint: NSLayoutConstraint!
    @IBOutlet weak var topOfMoreCommentsConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomOfWriterBoxConstraint: NSLayoutConstraint!
    
    var isTextLongEnoughToBeTruncated : Bool = true
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        likeButton.unclickedImage = #imageLiteral(resourceName: "thumbsUp")
        likeButton.clickedImage = #imageLiteral(resourceName: "thumbsUpClicked")
        dislikeButton.unclickedImage = #imageLiteral(resourceName: "thumbsDown")
        dislikeButton.clickedImage = #imageLiteral(resourceName: "thumbsDownClicked")
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        postImage.layer.shouldRasterize = true
        
        writeCommentBox.attributedText = NSAttributedString(string : "")
        writeCommentBox.placeholder = "Write a comment..."
        writeCommentBox.layer.borderColor = UIColor.gray.cgColor
        writeCommentBox.layer.borderWidth = 0.5
        
        removePaddingFromTextView(textView: singleCommentPreview)
        removePaddingFromTextView(textView: moreCommentsPreview)
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
