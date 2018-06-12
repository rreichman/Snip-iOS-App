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
    @IBOutlet var commentTimeLabel: UILabel!
    var comment: RealmComment!
    var delegate: CommentCellDelegate!
    
    @IBOutlet var replyLabel: UILabel!
    func bind(with comment: RealmComment) {
        self.comment = comment
        if let writer = comment.writer {
            nameLabel.text = "\(writer.first_name) \(writer.last_name)"
            shortName.text = writer.initials.uppercased()
        } else {
            nameLabel.text = ""
            shortName.text = ""
        }
        commentLabel.text = comment.body
        //Set indentation
        leadingConstraint.constant =  CGFloat(integerLiteral: 20 + (comment.level * 15))
        if comment.level < 2 {
            replyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onReply)))
            replyLabel.isHidden = false
        } else {
            replyLabel.isHidden = true
        }
        commentTimeLabel.text = comment.formattedTimeString()
    }
    
    @objc func onReply() {
        delegate.onReplyRequested(for: comment)
    }
}
