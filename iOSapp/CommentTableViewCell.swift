//
//  CommentTableViewCell.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/22/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell, UITextViewDelegate
{
    @IBOutlet weak var commentView: CommentView!
    
    // This is used to change the design of different levels
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellConstraintsAccordingToLevel(commentLevel : Int)
    {
        leftConstraint.constant = CGFloat(commentLevel * SystemVariables().COMMENT_INDENTATION_FROM_LEFT_PER_LEVEL)
    }
}
