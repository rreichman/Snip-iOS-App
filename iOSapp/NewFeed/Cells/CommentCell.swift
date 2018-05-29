//
//  CommentCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/24/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol CommentCellDelegate: class {
    func onReplyRequested(for comment: RealmComment)
}
class CommentCell: UITableViewCell {
    @IBOutlet var commentLabel: UILabel!
    
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var shortName: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var replayButton: UIButton!
    
    var comment: RealmComment!
    var delegate: CommentCellDelegate!
    func bind(with comment: RealmComment) {
        self.comment = comment
        if let writer = comment.writer {
            nameLabel.text = "\(writer.first_name) \(writer.last_name)"
            shortName.text = writer.initials
        } else {
            nameLabel.text = ""
            shortName.text = ""
        }
        commentLabel.text = comment.body
        //Set indentation
        leadingConstraint.constant =  CGFloat(integerLiteral: 20 + (comment.level * 15))
        if comment.level < 2 {
            replayButton.addTarget(self, action: #selector(onReply), for: .touchUpInside)
            replayButton.isHidden = false
        } else {
            replayButton.isHidden = true
        }
        
    }
    
    @objc func onReply() {
        delegate.onReplyRequested(for: comment)
    }
}
