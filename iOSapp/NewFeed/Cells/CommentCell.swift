//
//  CommentCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/24/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import Nuke

protocol CommentCellDelegate: class {
    func onReplyRequested(for comment: RealmComment)
    func onDeleteRequested(for comment: RealmComment)
    func onEditRequested(for comment: RealmComment)
}
class CommentCell: UITableViewCell {
    @IBOutlet var commentLabel: UILabel!
    
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var shortName: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var commentTimeLabel: UILabel!
    var comment: RealmComment!
    var delegate: CommentCellDelegate!
    
    @IBOutlet var deleteLabel: UILabel!
    @IBOutlet var editLabel: UILabel!
    @IBOutlet var replyLabel: UILabel!
    
    var hasGestureRecognizers: Bool = false
    
    func addGestureRecognizers() {
        replyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onReply)))
        editLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onEdit)))
        deleteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDelete)))
    }
    
    func bind(with comment: RealmComment, currentUser: User?) {
        
        if !hasGestureRecognizers {
            addGestureRecognizers()
            self.hasGestureRecognizers = true
        }
        self.comment = comment
        if let writer = comment.writer {
            nameLabel.text = "\(writer.first_name) \(writer.last_name)"
            shortName.text = writer.initials.uppercased()
            if writer.avatarUrl != "", let url = URL(string: writer.avatarUrl) {
                Nuke.loadImage(with: url, into: self.avatarImageView)
            } else {
                self.avatarImageView.image = nil
            }
            /**
            if writer.hasAvatarImageData() {
                avatarImageView.isHidden = false
                print("Avatar image size \(writer.avatarImage!.data!.count)")
                avatarImageView.contentMode = .scaleAspectFill
                avatarImageView.image = UIImage(data: writer.avatarImage!.data!, scale: 1000000.0 / CGFloat(writer.avatarImage!.data!.count))
            } else {
                avatarImageView.isHidden = true
                avatarImageView.image = UIImage()
            }
            **/
        } else {
            nameLabel.text = ""
            shortName.text = ""
            avatarImageView.image = nil
        }
        commentLabel.text = comment.body
        //Set indentation
        leadingConstraint.constant =  CGFloat(integerLiteral: 20 + (comment.level * 15))
        if comment.level < 2 {
            
            replyLabel.isHidden = false
        } else {
            replyLabel.isHidden = true
        }
        commentTimeLabel.text = comment.formattedTimeString()
        
        if let user = currentUser, let writer = comment.writer {
            if user.username == writer.username {
                editLabel.isHidden = false
                deleteLabel.isHidden = false
                editLabel.isUserInteractionEnabled = true
                deleteLabel.isUserInteractionEnabled = true
            } else {
                editLabel.isHidden = true
                deleteLabel.isHidden = true
                editLabel.isUserInteractionEnabled = false
                deleteLabel.isUserInteractionEnabled = false
            }
        }
    }
    
    @objc func onReply() {
        delegate.onReplyRequested(for: comment)
    }
    
    @objc func onEdit() {
        print("onEdit(), comment text \(comment.body)")
        delegate.onEditRequested(for: comment)
    }
    
    @objc func onDelete() {
        print("onDelete(), comment text \(comment.body)")
        delegate.onDeleteRequested(for: comment)
    }
}
