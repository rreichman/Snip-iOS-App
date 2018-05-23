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
}
protocol SnipCellDataDelegate: class {
    func writeVoteState(to: VoteState, for post: Post)
    func writeSaveState(saved: Bool, for post: Post)
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
    
    
    @IBOutlet var views: [UIView]!
    var delegate: SnipCellViewDelegate!
    var dataDelegate: SnipCellDataDelegate!
    var path: IndexPath!
    var expanded = false
    var bottomConstraint: NSLayoutConstraint!
    var dateFormatter: DateFormatter = DateFormatter()
    var postData: Post?
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
        commentInput.titleLabel?.textAlignment = .left
        bottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: postImage.bottomAnchor, constant: 20)
        //bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
        addTap()
    }
    
    func bind(data:Post, path: IndexPath, expanded: Bool) {
        self.path = path
        self.expanded = expanded
        
        //Binding of elements that will never be hindden
        titleLabel.text = data.headline
        if let auth = data.author {
            authorLabel.text = "\(auth.first_name) \(auth.last_name)"
        }
        dateLabel.text = dateFormatter.string(from: data.date)
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
            sourceLabel.text = "Source 1"
            //Bind butttons
        } else {
            bodyLabel.text = ""
            sourceLabel.text = ""
        }
        
        setBottomConstraint(large: expanded)
        setHiddenState(large: expanded)
    }
    
    func bindImage(imageOpt: Image?) {
        guard let image = imageOpt,
        let data = imageOpt?.data else {
            postImage.image = nil
            setActivityIndicatorState(loading: true)
            return
        }
        
        if data.count < 2 {
            setActivityIndicatorState(loading: true)
        } else {
            setActivityIndicatorState(loading: false)
            let ui_image = UIImage(data: data)
            postImage.image = ui_image
            postImage.layer.cornerRadius = 10
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
        dataDelegate.writeSaveState(saved: on, for: post)
    }
    func onToggleLike(on: Bool, for post: Post) {
        dataDelegate.writeVoteState(to: .like, for: post)
    }
    func onToggleDislike(on: Bool, for post: Post) {
        dataDelegate.writeVoteState(to: .dislike, for: post)
    }
    func addTap() {
        titleLabel.isUserInteractionEnabled = true
        bodyLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleTap)))
        bodyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleTap)))
    }

    @objc func titleTap() {
        print("\(self.path) tapped")
        delegate.setExpanded(large: !self.expanded, path: self.path)
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
