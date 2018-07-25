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
    
    @IBOutlet var readMoreLabel: UILabel!
    @IBOutlet var saveToggleButton: ToggleButton!
    weak var delegate: PostInteractionDelegate?
    
    private var viewModel: PostHeaderViewModel?
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstratint: NSLayoutConstraint?
    private var titleLabelHeightConstraint: NSLayoutConstraint?
    private var subheadlineHeightConstraint: NSLayoutConstraint?
    
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
        bindTitleView(titleText: viewModel.title)
        authorLabel.text = viewModel.authorName
        dateLabel.text = viewModel.dateString
        
        if let url = URL(string: viewModel.imageUrl) {
            Nuke.loadImage(with: url, into: postImage)
        } else {
            postImage.image = nil
        }
        bindSubheadline(subheadlineText: viewModel.subheadline)
        
        postImage.clipsToBounds = true
        postImage.contentMode = .scaleAspectFill
        
        saveToggleButton.bind(on_state: viewModel.saved) { [unowned self](value) in
            self.savePost()
        }
        if viewModel.expanded {
            readMoreLabel.isHidden = true
        } else {
            switch viewModel.postType {
            case .Explained:
                readMoreLabel.isHidden = true
            case .Report:
                if viewModel.emptySubhead {
                    readMoreLabel.isHidden = true
                } else {
                    readMoreLabel.isHidden = false
                    if viewModel.emptyBody {
                        readMoreLabel.text = "Expand"
                    } else {
                        readMoreLabel.text = "Read More"
                    }
                }
            }
        }
    }
    
    func bindTitleView(titleText: String) {
        self.titleLabelHeightConstraint?.isActive = false
        
        let titleLabelInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 146)
        let width = UIScreen.main.bounds.width
        //let authorLabelHeight = 16
        let titleTextSize = TextSize.size(titleText, font: UIFont.latoBold(size: 16), width: width, insets: titleLabelInsets)
        if titleTextSize.height > 86 {
            self.titleLabel.baselineAdjustment = .none
            self.titleLabel.adjustsFontSizeToFitWidth = true
            var size = titleTextSize
            var font: CGFloat = 16
            while size.height > 86 {
                font = font - 1
                size = TextSize.size(titleText, font: UIFont.latoBold(size: font), width: width, insets: titleLabelInsets)
            }
            self.titleLabel.font = UIFont.latoBold(size: font)
            self.titleLabelHeightConstraint = self.titleLabel.heightAnchor.constraint(equalToConstant: size.height)
            self.titleLabelHeightConstraint!.isActive = true
            self.titleLabel.text = titleText
        } else {
            self.titleLabel.font = UIFont.latoBold(size: 16)
            self.titleLabel.text = titleText
        }
        
    }
    
    func bindSubheadline(subheadlineText: NSAttributedString) {
        guard let model = self.viewModel, let _ = self.subheadTextView else {
            return
        }
        self.subheadlineHeightConstraint?.isActive = false
        let width = UIScreen.main.bounds.width
        /**
         Heading Cell
         Top Padding - 20
         Image height - 100
         Padding - 5
         Subheadline height - Variable
         Bottom padding - 0
         **/
        let subheadlineHeight = TextSize.sizeAttributed(subheadlineText, font: UIFont.lato(size: 15), width: width, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)).height
        
        self.subheadlineHeightConstraint = self.subheadTextView.heightAnchor.constraint(equalToConstant: subheadlineHeight)
        self.subheadlineHeightConstraint!.isActive = true
        
        self.subheadTextView.attributedText = subheadlineText
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewInit()
        bindView()
        addGestureRecognizers()
        
        self.contentView.backgroundColor = UIColor(white:0.97, alpha:1.0)
        self.subheadTextView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 125).isActive = true
        self.subheadTextView.tintColor = UIColor(white: 0.2, alpha: 1.0)
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
    
    @objc func expandPostImage() {
        guard let model = self.viewModel else { return }
        self.delegate?.showExpandedImage(postId: model.id)
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
        
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandPostImage)))
        
        readMoreLabel.isUserInteractionEnabled = true
        readMoreLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandPostAction)))
    }
}
