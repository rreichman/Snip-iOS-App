//
//  PostContentCollectionCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/19/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import IGListKit

class PostContentCollectionCell: UICollectionViewCell, ListBindable {
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var numberOfCommentsLabel: UILabel!
    @IBOutlet var voteControlView: VoteControl!
    @IBOutlet var bodyTextView: UITextViewFixed!
    @IBOutlet var views: [UIView]!
    
    weak var delegate: PostInteractionDelegate?
    
    private var viewModel: PostContentViewModel?
    private var bodyTextViewHeightConstraint: NSLayoutConstraint?
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? PostContentViewModel else { return }
        self.viewModel = viewModel
        bindView()
    }
    
    func bindView() {
        guard let viewModel = self.viewModel, let _ = self.commentButton else { return }
        if viewModel.numberOfComments == 0 {
            numberOfCommentsLabel.isHidden = true
        } else {
            numberOfCommentsLabel.isHidden = false
            numberOfCommentsLabel.text = (viewModel.numberOfComments == 1 ? "1 comment" : "\(viewModel.numberOfComments) comments")
        }
        commentButton.setTitle((viewModel.numberOfComments > 0 ? "Write a comment" : "Be the first to comment!"), for: .normal)
        voteControlView.bind(voteValue: viewModel.voteValue)
        voteControlView.delegate = self
        bindBodyText(bodyText: viewModel.body)
    }
    
    func bindBodyText(bodyText: NSAttributedString) {
        guard let _ = self.viewModel, let _ = self.bodyTextView else {
            return
        }
        self.bodyTextViewHeightConstraint?.isActive = false
        let width = UIScreen.main.bounds.width
        /**
         Content Cell
         Top Padding 0
         Body - Variable
         Vote View 44
         Padding 10
         Comment Input 64
         Padding 10
         **/
        let bodyTextViewHeight = TextSize.sizeAttributed(bodyText, font: UIFont.lato(size: 15), width: width, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)).height
        self.bodyTextViewHeightConstraint = self.bodyTextView.heightAnchor.constraint(equalToConstant: bodyTextViewHeight)
        self.bodyTextViewHeightConstraint!.isActive = true
        
        self.bodyTextView.attributedText = bodyText
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bindView()
        
        for view in self.views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addGestureRecognizers()
        self.contentView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        commentButton.layer.cornerRadius = 14
        commentButton.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        commentButton.layer.borderWidth = 1
        commentButton.titleLabel?.contentMode = .center
    }
    
    @objc func expandPost() {
        if let d = self.delegate, let model = self.viewModel {
            d.setExpanded(postId: model.id, !model.expanded)
        }
    }
    
    func addGestureRecognizers() {
        bodyTextView.isUserInteractionEnabled = true
        bodyTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandPost)))
        
        commentButton.isUserInteractionEnabled = true
        commentButton.addTarget(self, action: #selector(writePostComment), for: .touchUpInside)
        
        numberOfCommentsLabel.isUserInteractionEnabled = true
        numberOfCommentsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPostComments)))
        
        shareButton.addTarget(self, action: #selector(sharePost), for: .touchUpInside)
        
    }
    
    func setVoteValue(value: Double) {
        if let d = self.delegate, let model = self.viewModel {
            d.setVoteValue(postId:model.id, value: value)
        }
    }
    
    @objc func showPostComments() {
        if let d = self.delegate, let model = self.viewModel {
            d.showPostDetail(postId: model.id, startComment: false)
        }
    }
    
    @objc func writePostComment() {
        if let d = self.delegate, let model = self.viewModel {
            d.showPostDetail(postId: model.id, startComment: true)
        }
    }
    
    @objc func sharePost() {
        if let d = self.delegate, let model = self.viewModel {
            d.sharePost(postTitle: model.title, postUrlString: model.postUrl, sourceView: shareButton)
        }
    }
}

extension PostContentCollectionCell: VoteControlDelegate {
    func voteValueSet(to: Double) {
        self.setVoteValue(value: to)
    }
    
    
}
