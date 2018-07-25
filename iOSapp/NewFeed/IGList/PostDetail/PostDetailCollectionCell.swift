//
//  PostDetailCollectionCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/23/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import IGListKit
import Nuke

class PostDetailCollectionCell: UICollectionViewCell, ListBindable {
    weak var delegate: PostInteractionDelegate?
    
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var avatarInitialsLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var voteControl: VoteControl!
    @IBOutlet var postDateLabel: UILabel!
    @IBOutlet var authorInitialsLabel: UILabel!
    @IBOutlet var subheadlineTextView: UITextView!
    @IBOutlet var postOptionsButton: UIImageView!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var bodyTextView: UITextViewFixed!
    @IBOutlet var numberOfCommentsLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var views: [UIView]!
    
    var model: PostExpandedViewModel?
    
    func bindViewModel(_ viewModel: Any) {
        guard let model = viewModel as? PostExpandedViewModel else { fatalError() }
        self.model = model
        bindView()
        constrainTextViews()
    }
    
    func bindView() {
        guard let _ = self.bodyTextView, let model = self.model else { return }
        if let url = URL(string: model.imageUrl) {
            self.postImageView.isHidden = false
            Nuke.loadImage(with: url, into: self.postImageView)
        } else {
            self.postImageView.isHidden = true
        }
        
        if let avatarUrl = URL(string: model.authorAvatarUrl) {
            self.avatarImageView.isHidden = false
            self.authorInitialsLabel.isHidden = true
            Nuke.loadImage(with: avatarUrl, into: avatarImageView)
        } else {
            self.avatarImageView.isHidden = true
            self.authorInitialsLabel.isHidden = false
            self.authorInitialsLabel.text = model.authorInitials
        }
        
        self.authorLabel.text = model.authorName
        self.postDateLabel.text = model.dateString
        self.titleLabel.text = model.title
        self.subheadlineTextView.attributedText = model.subhead
        self.bodyTextView.attributedText = model.body
        self.numberOfCommentsLabel.text = model.numberOfComments == 1 ? "1 Comment" : "\(model.numberOfComments) Comments"
        constrainTextViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bindTouches()
        self.postImageView.layer.cornerRadius = 5
        self.postImageView.clipsToBounds = true
        let imageHeight = (UIScreen.main.bounds.width - 32) * 0.666
        self.postImageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
        
        views.forEach { (view) in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        constrainTextViews()
    }
    
    
    func constrainTextViews() {
        guard let model = self.model, let _ = self.bodyTextView else { return }
        let width = UIScreen.main.bounds.width
        let imageHeight = (UIScreen.main.bounds.width - 32) * 0.666
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let titleHeight = TextSize.size(model.title, font: UIFont.latoBold(size: 16), width: width, insets: insets).height
        
        
        
        let subheadY = 86 + titleHeight + imageHeight
        self.subheadlineTextView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: subheadY).isActive = true
        
        let subheadHeight = TextSize.sizeAttributed(model.subhead, font: UIFont.lato(size: 15), width: width, insets: insets).height
        self.subheadlineTextView.heightAnchor.constraint(equalToConstant: subheadHeight).isActive = true
        
        let bodyY = subheadY + subheadHeight
        self.bodyTextView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: bodyY).isActive = true
        let bodyHeight = TextSize.sizeAttributed(model.body, font: UIFont.lato(size: 14), width: width, insets: insets).height + 10
        
        bodyTextView.heightAnchor.constraint(equalToConstant: bodyHeight).isActive = true
    }
    
    func bindTouches() {
        self.authorLabel.isUserInteractionEnabled = true
        self.authorLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showWriterPosts)))
        
        self.postImageView.isUserInteractionEnabled = true
        self.postImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandPostImage)))
        
        self.postOptionsButton.isUserInteractionEnabled = true
        self.postOptionsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPostOptions)))
        
        self.shareButton.addTarget(self, action: #selector(sharePost), for: .touchUpInside)
    }
    
    @objc func sharePost() {
        guard let delegate = self.delegate, let model = self.model else { return }
        delegate.sharePost(postTitle: model.title, postUrlString: model.urlString, sourceView: self.shareButton)
    }
    
    @objc func showPostOptions() {
        guard let delegate = self.delegate, let model = self.model else { return }
        delegate.showPostOptions(postId: model.id)
    }
    
    @objc func expandPostImage() {
        guard let delegate = self.delegate, let model = self.model else { return }
        delegate.showExpandedImage(postId: model.id)
    }
    
    @objc func showWriterPosts() {
        guard let delegate = self.delegate, let model = self.model else { return }
        delegate.showWritersPosts(writerUserName: model.authorUsername)
    }

}

extension PostDetailCollectionCell: VoteControlDelegate {
    func voteValueSet(to: Double) {
        guard let model = self.model else { return }
        self.delegate?.setVoteValue(postId: model.id, value: to)
    }
    
    
}
