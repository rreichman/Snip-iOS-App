//
//  NewSnippetTableViewCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

protocol SnipTableViewDelegate: class {
    func setExpanded(large: Bool, path: IndexPath)
}

class NewSnippetTableViewCell: UITableViewCell {
    static let cellReuseIdentifier = "NewSnippetTableViewIdentifier"
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var commentInput: UIButton!
    @IBOutlet var sourceLabel: UILabel!
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var optionsButton: UIButton!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet var views: [UIView]!
    var delegate: SnipTableViewDelegate!
    var path: IndexPath!
    var expanded = false
    var bottomConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        contentView.backgroundColor = UIColor.white
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
            authorLabel.text = auth.name
        }
        dateLabel.text = "2h"
        bindImage(imageOpt: data.image)
        //Binding of elements that might be hidden
        if expanded {
            bodyLabel.text = data.text
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
        guard let image = imageOpt else {
            setActivityIndicatorState(loading: true)
            return
        }
        
        guard let data = image.data else {
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
    
    func addTap() {
        titleLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(titleTap))
        titleLabel.addGestureRecognizer(tap)
    }
    @objc func titleTap() {
        print("\(self.path) tapped")
        delegate.setExpanded(large: !self.expanded, path: self.path)
    }
    
}
