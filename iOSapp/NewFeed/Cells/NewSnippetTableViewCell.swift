//
//  NewSnippetTableViewCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

protocol SnipCellViewDelegate: class {
    func setExpanded(large: Bool, path: IndexPath)
    func share(msg: String, url: NSURL, sourceView: UIView)
    func postOptions(for post: Post)
    func showDetail(for post: Post)
    func viewWriterPost(writer: User)
}
protocol SnipCellDataDelegate: class {
    func onVoteAciton(action: VoteAction, for post: Post)
    func onSaveAciton(saved: Bool, for post: Post)
    
}

class NewSnippetTableViewCell: UITableViewCell {
    static let cellReuseIdentifier = "NewSnippetTableViewIdentifier"
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var commentInput: UIButton!
    @IBOutlet var sourceLabel: UILabel!
    
    @IBOutlet var saveButton: ToggleButton!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var optionsButton: UIButton!
    @IBOutlet var dislikeButton: ToggleButton!
    @IBOutlet var likeButton: ToggleButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var numberOfCommentsLabel: UILabel!
    @IBOutlet var touchAreaView: UIView!
    
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
    
    func viewInit() {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        postImage.layer.cornerRadius = 10
        contentView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        commentInput.layer.cornerRadius = 16
        commentInput.layer.borderWidth = 1
        commentInput.layer.borderColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0).cgColor
        //commentInput.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        //commentInput.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);

        bottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: postImage.bottomAnchor, constant: 20)
        //bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
        addTap()
        dislikeButton.contentMode = .center
        dislikeButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func bind(data:Post, path: IndexPath, expanded: Bool) {
        self.path = path
        self.expanded = expanded
        
        //Binding of elements that will never be hindden
        titleLabel.text = data.headline
        if let auth = data.author {
            authorLabel.text = "\(auth.first_name) \(auth.last_name)"
        }
        dateLabel.text = data.formattedTimeString()
        bindImage(imageOpt: data.image)
        saveButton.bind(on_state: data.saved) { [data] (on) in
            self.onToggleSave(on: on, for: data)
        }
        likeButton.bind(on_state: data.isLiked) { [data] (on) in
            self.onToggleLike(on: on, for: data)
        }
        dislikeButton.bind(on_state: data.isDisliked) {[data] (on) in
            self.onToggleDislike(on: on, for: data)
        }
        //Binding of elements that might be hidden
        if expanded {
            if let richText = data.getAttributedBody() {
                bodyLabel.attributedText = richText
            } else {
                bodyLabel.text = data.text
            }
            var sourceString = ""
            for source in data.relatedLinks {
                sourceString += "\(source.title), "
            }
            if sourceString.count > 0 {
                sourceString = String(sourceString[..<sourceString.index(sourceString.endIndex, offsetBy: -2)])
            }
            sourceLabel.text = sourceString
            
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
            bodyLabel.text = ""
            sourceLabel.text = ""
            numberOfCommentsLabel.isHidden = true
        }
        self.shareMessage = "Check out this snippet:\n" + data.headline + " "
        self.shareUrl = NSURL(string: data.fullURL)
        
        setBottomConstraint(large: expanded)
        setHiddenState(large: expanded)
        
        commentInput.addTarget(self, action: #selector(commentTap), for: .touchUpInside)
        self.post = data
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
        }
    }
    
    func setBottomConstraint(large: Bool) {
        bottomConstraint.isActive = false
        if large {
            bottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: commentInput.bottomAnchor, constant: 20)
        } else {
            bottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: postImage.bottomAnchor, constant: 20)
        }
        //bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
    }
    
    func setHiddenState(large: Bool) {
        let hidden = !large
        bodyLabel.isHidden = hidden
        sourceLabel.isHidden = hidden
        dislikeButton.isHidden = hidden
        likeButton.isHidden = hidden
        shareButton.isHidden = hidden
        commentInput.isHidden = hidden
    }
    
    func onToggleSave(on: Bool, for post: Post) {
        print("onToggleSave on:\(on)")
        dataDelegate.onSaveAciton(saved: on, for: post)
    }
    func onToggleLike(on: Bool, for post: Post) {
        let action: VoteAction = on ? .likeOn : .likeOff
        dataDelegate.onVoteAciton(action: action, for: post)
    }
    func onToggleDislike(on: Bool, for post: Post) {
        let action: VoteAction = on ? .dislikeOn : .dislikeOff
        dataDelegate.onVoteAciton(action: action, for: post)
    }
    func addTap() {
        titleLabel.isUserInteractionEnabled = true
        bodyLabel.isUserInteractionEnabled = true
        authorLabel.isUserInteractionEnabled = true
        numberOfCommentsLabel.isUserInteractionEnabled = true
        numberOfCommentsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(commentTap)))
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleTap)))
        bodyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleTap)))
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(postOptionsTab), for: .touchUpInside)
        authorLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(authorTap)))
        
        touchAreaView.isUserInteractionEnabled = true
        touchAreaView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleTap)))
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
    
    @objc func commentTap() {
        guard let p = self.post else { return }
        delegate.showDetail(for: p)
    }
    
    @objc func postOptionsTab() {
        guard let p = self.post else { return }
        delegate.postOptions(for: p)
    }
}

extension Post {
    func getAttributedBody() -> NSMutableAttributedString? {
        //Possibly strip paragraphs
        guard let render = NSMutableAttributedString(htmlString: text) else { return nil }
        render.addAttributes([NSAttributedStringKey.font: UIFont.lato(size: 14), NSAttributedStringKey.foregroundColor: UIColorFromRGB(rgbValue: 0x4c4c4c)], range: NSRange(location: 0, length: render.length))
        return render
    }
}
