//
//  CommentCollectionController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/23/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import IGListKit
import Nuke

protocol CommentCollectionDelegate: class {
    func replyToComment(parentCommentId: Int)
    func editComment(commentId: Int)
    func deleteComment(commentId: Int)
}

class CommentCollectionCell: UICollectionViewCell, ListBindable {
    
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var initialsLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var replyLabel: UILabel!
    @IBOutlet var deleteLabel: UILabel!
    @IBOutlet var editLabel: UILabel!
    
    var model: CommentViewModel?
    var commentDelegate: CommentCollectionDelegate?
    
    func bindViewModel(_ viewModel: Any) {
        guard let model = viewModel as? CommentViewModel else { fatalError() }
        self.model = model
        bindView()
    }
    
    func bindView() {
        guard let model = self.model, let _ = self.commentLabel else { return }
        
        self.commentLabel.text = model.body
        self.nameLabel.text = model.writerName
        self.dateLabel.text = model.dateString
        
        if let url = URL(string: model.avatarUrlString) {
            self.avatarImageView.isHidden = false
            self.initialsLabel.isHidden = true
            Nuke.loadImage(with: url, into: avatarImageView)
        } else {
            self.avatarImageView.isHidden = true
            self.initialsLabel.isHidden = false
            self.initialsLabel.text = model.writerInitials
        }
        
        if model.writerUsername == model.activeUserUsername {
            self.editLabel.isHidden = false
            self.deleteLabel.isHidden = false
        } else {
            self.editLabel.isHidden = true
            self.deleteLabel.isHidden = true
        }
        
        if model.level > 1 {
            replyLabel.isHidden = true
        } else {
            replyLabel.isHidden = false
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func addGestureRecognizers() {
        self.replyLabel.isUserInteractionEnabled = true
        self.replyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(replyToComment)))
    }
    
    @objc func replyToComment() {
        guard let delegate = self.commentDelegate, let model = self.model else { return }
        delegate.replyToComment(parentCommentId: model.id)
        
    }
    
    @objc func editComment() {
        guard let delegate = self.commentDelegate, let model = self.model else { return }
        delegate.editComment(commentId: model.id)
    }
    
    @objc func deleteComment() {
        guard let delegate = self.commentDelegate, let model = self.model else { return }
        delegate.deleteComment(commentId: model.id)
    }

}
