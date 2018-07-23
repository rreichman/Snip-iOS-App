//
//  PostHeaderCollectionCellCollectionViewCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/19/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import IGListKit
import Nuke
class PostHeaderCollectionCell: UICollectionViewCell, ListBindable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var subheadTextView: UITextViewFixed!
    @IBOutlet var postOptionsButton: UIButton!
    @IBOutlet var views: [UIView]!
    
    @IBOutlet var saveToggleButton: ToggleButton!
    weak var delegate: PostInteractionDelegate?
    
    private var viewModel: PostHeaderViewModel?
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstratint: NSLayoutConstraint?
    
    func viewInit() {
        for view in self.views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? PostHeaderViewModel else { return }
        self.viewModel = viewModel
        bindView()
    }
    
    func bindView() {
        guard let viewModel = self.viewModel, let _ = self.postImage else { return }
        titleLabel.text = viewModel.title
        authorLabel.text = viewModel.authorName
        dateLabel.text = viewModel.dateString
        
        if let url = URL(string: viewModel.imageUrl) {
            Nuke.loadImage(with: url, into: postImage)
        } else {
            postImage.image = nil
        }
        subheadTextView.attributedText = viewModel.subheadline
        
        postImage.clipsToBounds = true
        postImage.contentMode = .scaleAspectFill
        
        saveToggleButton.bind(on_state: viewModel.saved) { [unowned self](value) in
            self.savePost()
        }
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewInit()
        bindView()
        addGestureRecognizers()
        
        self.contentView.backgroundColor = UIColor(white:0.97, alpha:1.0)
        postImage.layer.cornerRadius = 4
    }
    
    @objc func expandPostAction() {
        if let d = self.delegate, let v = self.viewModel {
            d.setExpanded(postId: v.id, !v.expanded)
        }
    }
    
    @objc func showWritersPosts() {
        if let d = self.delegate, let model = self.viewModel {
            d.showWritersPosts(writerUserName: model.authorUsername)
        }
    }
    
    @objc func postOptionsAction() {
        if let d = self.delegate, let model = self.viewModel {
            d.showPostOptions(postId: model.id)
        }
    }
    
    func savePost() {
        if let d = self.delegate, let model = self.viewModel {
            d.savePost(postId: model.id)
        }
    }
    
    func addGestureRecognizers() {
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandPostAction)))
        
        subheadTextView.isUserInteractionEnabled = true
        subheadTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandPostAction)))
        authorLabel.isUserInteractionEnabled = true
        authorLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showWritersPosts)))
        
        postOptionsButton.addTarget(self, action: #selector(postOptionsAction), for: .touchUpInside)
    }
}
