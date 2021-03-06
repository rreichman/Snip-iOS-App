//
//  NewSnippetTableViewCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import Crashlytics

protocol SnipCellViewDelegate: class {
    func setExpanded(large: Bool, path: IndexPath)
    func share(msg: String, url: NSURL, sourceView: UIView)
    func postOptions(for post: Post)
    func showDetail(for post: Post, startComment: Bool)
    func viewWriterPost(writer: User)
    func showExpandedImage(for post: Post)
}
protocol SnipCellDataDelegate: class {
    func onVoteAciton(newVoteValue: Double, for post: Post)
    func onSaveAciton(saved: Bool, for post: Post)
    
}

class NewSnippetTableViewCell: UITableViewCell {
    static let cellReuseIdentifier = "NewSnippetTableViewIdentifier"
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var commentInput: UIButton!
    
    @IBOutlet var subheadTextView: UITextViewFixed!
    @IBOutlet var extraTouchArea: UIView!
    @IBOutlet var bodyTextView: UITextViewFixed!
    @IBOutlet var saveButton: ToggleButton!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var optionsButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var numberOfCommentsLabel: UILabel!
    //@IBOutlet var touchAreaView: UIView!
    
    @IBOutlet var voteControl: VoteControl!
    @IBOutlet var views: [UIView]!
    var delegate: SnipCellViewDelegate!
    var dataDelegate: SnipCellDataDelegate!
    var path: IndexPath!
    var expanded = false
    var bottomConstraint: NSLayoutConstraint!
    var dateFormatter: DateFormatter = DateFormatter()
    var shareMessage: String?
    var shareUrl: NSURL?
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        viewInit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
        titleLabel.preferredMaxLayoutWidth = titleLabel.bounds.size.width
    }
    
    func viewInit() {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        postImage.layer.cornerRadius = 10
        contentView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        commentInput.layer.cornerRadius = 16
        commentInput.layer.borderWidth = 1
        commentInput.layer.borderColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0).cgColor
        voteControl.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)

        bottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: subheadTextView.bottomAnchor, constant: 20)
        bottomConstraint.priority = .init(999.0)
        bottomConstraint.isActive = true
        addTap()
        
    }
    
    func bind(data:Post, path: IndexPath, expanded: Bool) {
        self.path = path
        self.expanded = expanded
        
        //Binding of elements that will never be hindden
        titleLabel.text = data.headline
        titleLabel.sizeToFit()
        titleLabel.needsUpdateConstraints()
        titleLabel.layoutIfNeeded()
        if let auth = data.author {
            authorLabel.text = "\(auth.first_name) \(auth.last_name)"
        }
        dateLabel.text = data.formattedTimeString()
        bindImage(imageOpt: data.image)
        saveButton.bind(on_state: data.saved) { [data] (value) in
            var on: Bool!
            switch value {
            case .on:
                on = true
            case .fractional:
                //this will never happen with the save button
                on = false
            case .off:
                on = false
            }
            self.onToggleSave(on: on, for: data)
        }
        voteControl.bind(voteValue: data.voteValue)
        voteControl.delegate = self
        
        if data.postType == PostType.Report, let subheadRichText = data.getAttributedSubheadMutable() {
            subheadTextView.attributedText = subheadRichText
            subheadTextView.isHidden = false
        } else {
            subheadTextView.text = ""
            subheadTextView.isHidden = true
        }
        
        //Binding of elements that might be hidden
        if expanded {
            if let richText = data.getAttributedBodyMutable() {
                
                //Who knows if anyone really understands how Attributed Text works, it doesnt seem like there is much of anything about it on google
                richText.append(NSAttributedString(string: "\n"))
                let pStyle = NSMutableParagraphStyle()
                pStyle.lineSpacing = 0.0
                pStyle.paragraphSpacing = 12
                pStyle.defaultTabInterval = 36
                pStyle.baseWritingDirection = .leftToRight
                pStyle.minimumLineHeight = 20.0
                
                for source in data.relatedLinks {
                    guard let url = URL(string: source.url) else {
                        print("Post \(data.id) has an invalid related link URL \(source.url)")
                        Crashlytics.sharedInstance().recordError(SerializationError.invalid("Related link URL", source.url), withAdditionalUserInfo: ["title": source.title, "url": source.url, "post_id": data.id, "api_url": RestUtils.snipURLString])
                        continue
                    }
                    let text = source.title + ", "
                    
                    let attributes: [NSAttributedStringKey : Any] =
                        [.paragraphStyle: pStyle,
                         .foregroundColor: UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1.0),
                         .font: UIFont.lato(size: 15),
                         .link: url]
                    let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
                    richText.append(attributedText)
                }
                bodyTextView.attributedText = (richText.length > 2 ? richText.attributedSubstring(from: NSMakeRange(0, richText.length - 2)) : richText)
                bodyTextView.sizeToFit()
                bodyTextView.layoutSubviews()
            } else {
                bodyTextView.text = data.text
            }
            bodyTextView.tintColor = UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1.0)
            
            if data.comments.count > 0 {
                numberOfCommentsLabel.isHidden = false
                numberOfCommentsLabel.text = "\(data.comments.count) comment" + (data.comments.count != 1 ? "s" : "")
                commentInput.setTitle("Write a comment ...", for: .normal)
            } else {
                numberOfCommentsLabel.isHidden = true
                commentInput.setTitle("Be the first to comment ...", for: .normal)
            }
            //Bind butttons
        } else {
            bodyTextView.text = ""
            numberOfCommentsLabel.isHidden = true
        }
        self.shareMessage = "Check out this snippet:\n" + data.headline + " "
        self.shareUrl = NSURL(string: data.fullURL)
        
        setBottomConstraint(large: expanded)
        setHiddenState(large: expanded)
        
        self.post = data
        
        if !data.postHasBeenExpanded && expanded{
            data.postHasBeenExpanded = true
            
            SnipLoggerRequests.instance.logPostReadMore(postId: data.id)
        }
        
        if !data.postHasBeenViewed {
            data.postHasBeenViewed = true
            
            SnipLoggerRequests.instance.logPostView(postId: data.id)
        }
    }
    
    func bindImage(imageOpt: Image?) {
        guard let image = imageOpt else {
            postImage.image = nil
            setActivityIndicatorState(loading: false)
            return
        }
        
        guard let data = image.data else {
            postImage.image = nil
            setActivityIndicatorState(loading: !image.failed_loading)
            return
        }
        
        if data.count < 2 {
            setActivityIndicatorState(loading: true)
        } else {
            setActivityIndicatorState(loading: false)
            let ui_image = UIImage(data: data)
            postImage.image = ui_image
            postImage.layer.cornerRadius = 5
            postImage.layer.masksToBounds = true
        }
        //set image to data
    }
    
    func setActivityIndicatorState(loading: Bool) {
        if loading {
            postImage.image = nil
            postImage.backgroundColor = UIColor.black
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            postImage.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        }
    }
    
    func setBottomConstraint(large: Bool) {
        bottomConstraint.isActive = false
        if large {
            bottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: commentInput.bottomAnchor, constant: 20)
        } else {
            bottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: subheadTextView.bottomAnchor, constant: 20)
        }
        bottomConstraint.priority = .init(999)
        bottomConstraint.isActive = true
    }
    
    func setHiddenState(large: Bool) {
        let hidden = !large
        bodyTextView.isHidden = hidden
        voteControl.isHidden = hidden
        shareButton.isHidden = hidden
        commentInput.isHidden = hidden
    }
    
    func onToggleSave(on: Bool, for post: Post) {
        print("onToggleSave on:\(on)")
        dataDelegate.onSaveAciton(saved: on, for: post)
    }
    
    func addTap() {
        titleLabel.isUserInteractionEnabled = true
        bodyTextView.isUserInteractionEnabled = true
        authorLabel.isUserInteractionEnabled = true
        numberOfCommentsLabel.isUserInteractionEnabled = true
        numberOfCommentsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewCommentsTap)))
        commentInput.addTarget(self, action: #selector(startCommentTap), for: .touchUpInside)
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleTap)))
        bodyTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleTap)))
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(postOptionsTab), for: .touchUpInside)
        authorLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(authorTap)))
        
        extraTouchArea.isUserInteractionEnabled = true
        extraTouchArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleTap)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTap)))
        
        subheadTextView.isUserInteractionEnabled = true
        subheadTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.titleTap)))
    }
    
    @objc func imageTap() {
        guard let p = self.post else { return }
        delegate.showExpandedImage(for: p)
        
        SnipLoggerRequests.instance.logImageExpanded(postId: p.id)
    }
    
    @objc func authorTap() {

        if let a = post?.author {
            delegate.viewWriterPost(writer: a)
        }
        
    }

    @objc func titleTap() {
        print("\(self.path) tapped")
        delegate.setExpanded(large: !self.expanded, path: self.path)
    }
    
    @objc func shareTap() {
        guard
            let msg = self.shareMessage,
            let url = self.shareUrl else { return }
        delegate.share(msg: msg, url: url, sourceView: shareButton)
    }
    
    @objc func startCommentTap() {
        guard let p = self.post else { return }
        delegate.showDetail(for: p, startComment: true)
    }
    
    @objc func viewCommentsTap() {
        guard let p = self.post else { return }
        delegate.showDetail(for: p, startComment: false)
    }
    
    @objc func postOptionsTab() {
        guard let p = self.post else { return }
        delegate.postOptions(for: p)
        
        SnipLoggerRequests.instance.logPostReadMore(postId: p.id)
    }
}

extension NewSnippetTableViewCell: VoteControlDelegate {
    func voteValueSet(to value: Double) {
        guard let p = self.post else { return }
        dataDelegate.onVoteAciton(newVoteValue: value, for: p)
    }
    
    
}
