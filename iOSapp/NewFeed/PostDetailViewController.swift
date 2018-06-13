//
//  PostDetailViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/23/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

protocol PostDetailViewDelegate: class {
    func share(msg: String, url: NSURL, sourceView: UIView)
    func postComment(for post: Post, with body: String, parent: RealmComment?)
    func onBackPressed()
    func showLoginSignUp()
}

class PostDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var bodyTextView: UITextViewFixed!
    @IBOutlet var sourceTextView: UITextViewFixed!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var optionsButton: UIImageView!
    @IBOutlet var dislikeButton: ToggleButton!
    @IBOutlet var likeButton: ToggleButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var shortAuthorLabel: UILabel!
    @IBOutlet var writeBoxContainer: UIView!
    @IBOutlet var postContainer: UIView!
    @IBOutlet var postCommentButton: UIButton!
    @IBOutlet var numberOfCommentsLabel: UILabel!
    @IBOutlet var commentText: UITextField!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var statusContainer: UIView!
    @IBOutlet var cancelReplyButton: UIButton!
    @IBOutlet var replyToLabel: UILabel!
    
    @IBOutlet var writeBoxDivider: UIView!
    var delegate: PostDetailViewDelegate!
    var dataDelegate: SnipCellDataDelegate!
    var dateFormatter: DateFormatter = DateFormatter()
    var shareMessage: String?
    var shareUrl: NSURL?
    
    var post: Post!
    var commentArray: [ RealmComment ]?
    var replyComment: RealmComment?
    var token: NotificationToken?
    var topConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        tableView.dataSource = self
        //tableView.tableHeaderView = postContainer
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        bodyTextView.delegate = self
        dataDelegate = PostStateManager.instance
        whiteBackArrow()
        viewInit()
        dynamicKeyboardViewPosition()
        setUpWriteBox()
        
        
        bodyTextView.isScrollEnabled = false
        postCommentButton.addTarget(self, action: #selector(onSend), for: .touchUpInside)
        cancelReplyButton.addTarget(self, action: #selector(onCancelReply), for: .touchUpInside)
        topConstraint = writeBoxDivider.bottomAnchor.constraint(equalTo: commentText.topAnchor)
        topConstraint.isActive = true
        
        //postContainer.autoresizingMask = .flexibleWidth

        self.bindViews(data: self.post)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
    
    func sizeHeaderToFit() {
        let headerView = tableView.tableHeaderView!
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        let actual_header_height = headerView.frame.size.height
        let contentSize = bodyTextView.contentSize
        let frame_size = bodyTextView.frame.size.height
        let intrinsicContentSize = bodyTextView.intrinsicContentSize
        let post = self.post
        let text = bodyTextView.text
        
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
    }
    
    func viewInit() {
        
        postImage.layer.cornerRadius = 10
        //contentView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        addTap()
    }
    
    func toggleReplyStatus(show: Bool) {
        topConstraint.isActive = false
        if show {
            topConstraint = writeBoxDivider.bottomAnchor.constraint(equalTo: statusContainer.topAnchor)
            statusContainer.isHidden = false
        } else {
            topConstraint = writeBoxDivider.bottomAnchor.constraint(equalTo: commentText.topAnchor)
            statusContainer.isHidden = true
        }
        topConstraint.isActive = true
    }
    
    func bind(data: Post) {
        self.post = data
        bindViews(data: data)
    }
    
    
    func bindViews(data: Post) {
        guard let _ = self.tableView else { return }
        //Binding of elements that will never be hindden
        titleLabel.text = data.headline
        if let auth = data.author {
            authorLabel.text = "\(auth.first_name) \(auth.last_name)"
            shortAuthorLabel.text = auth.initials.uppercased()
        }
        dateLabel.text = dateFormatter.string(from: data.date)
        bindImage(imageOpt: data.image)
        /**saveButton.bind(on_state: data.saved) { [data] (on) in
            self.onToggleSave(on: on, for: data)
        }**/
        likeButton.bind(on_state: data.isLiked) { [data] (on) in
            self.onToggleLike(on: on, for: data)
        }
        dislikeButton.bind(on_state: data.isDisliked) {[data] (on) in
            self.onToggleDislike(on: on, for: data)
        }
        if let richText = data.getAttributedBody() {
            //Who knows if anyone really understands how Attributed Text works, it doesnt seem like there is much of anything about it on google
            let pStyle = NSMutableParagraphStyle()
            pStyle.lineSpacing = 0.0
            pStyle.paragraphSpacing = 12
            pStyle.defaultTabInterval = 36
            pStyle.baseWritingDirection = .leftToRight
            pStyle.minimumLineHeight = 15.0
            
            for source in data.relatedLinks {
                let text = source.title + ", "
                
                let attributes: [NSAttributedStringKey : Any] =
                    [.paragraphStyle: pStyle,
                     .foregroundColor: UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1.0),
                     .font: UIFont.lato(size: 14),
                     .link: URL(string: source.url)!]
                let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
                richText.append(attributedText)
            }
            bodyTextView.attributedText = (data.relatedLinks.count > 0 ? richText.attributedSubstring(from: NSMakeRange(0, richText.length - 2)) : richText)
            //bodyTextView.sizeToFit()
        } else {
            bodyTextView.text = data.text
        }
        bodyTextView.tintColor = UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1.0)
        var sourceString = ""
        for source in data.relatedLinks {
            sourceString += "\(source.title), "
        }
        if sourceString.count > 0 {
            sourceString = String(sourceString[..<sourceString.index(sourceString.endIndex, offsetBy: -2)])
        }
        //sourceLabel.text = sourceString
        //sourceTextView.text = sourceString
        self.shareMessage = "Check out this snippet:\n" + data.headline
        self.shareUrl = NSURL(string: data.fullURL)
        
        let comment_count = data.comments.count
        bindNumberOfCommentsLabel(comment_count: comment_count)
        
        self.commentArray = calculateCommentArray(for: data)
        
        
        self.token = data.comments.observe({ [weak self](changes) in
            guard let s = self else { return }
            s.commentArray = s.calculateCommentArray(for: s.post)
            guard let comments = s.commentArray else { return }
            s.bindNumberOfCommentsLabel(comment_count: comments.count)
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                s.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                
                UIView.performWithoutAnimation {
                    // Just another thing that started so promising and ends so poorly. With animations broken and now update maps not even working, realm isnt really even adding any value anymore
                    /**
                     s.tableView.beginUpdates()
                     s.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: index) }),
                     with: .none)
                     s.tableView.reloadRows(at: insertions.map({ IndexPath(row: $0, section: index) }),
                     with: .none)
                     
                     s.tableView.endUpdates()
                     **/
                    
                    s.tableView.reloadData()
                }
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        })
        
        
    }
    
    func bindNumberOfCommentsLabel(comment_count: Int) {
        let comment_string = "\(comment_count) comment" + (comment_count != 1 ? "s" : "")
        self.numberOfCommentsLabel.text = comment_string
    }
    
    func bindImage(imageOpt: Image?) {
        guard let _ = imageOpt,
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
    
    
    //Why doesnt the server do this?
    func calculateCommentArray(for post: Post) -> [ RealmComment ] {
        if post.comments.count == 0 {
            return []
        }
        var post_comments = formList(from: post.comments)
        post_comments.sort { (c1, c2) -> Bool in
           return c1.date.compare(c2.date).rawValue > 0
        }
        nestTimeSortedCommentArray(of: post_comments)
        var unNestedComments: [ RealmComment ] = []
        for comment in post_comments {
            if comment.level == 0 {
                unNestedComments.append(contentsOf: flattenComments(parent: comment))
            }
        }
        return unNestedComments
    }
    
    func flattenComments(parent: RealmComment) -> [ RealmComment ] {
        var flat: [ RealmComment ] = []
        flat.append(parent)
        if parent.childComments.count > 0 {
            for child in parent.childComments {
                flat.append(contentsOf: flattenComments(parent: child))
            }
        }
        return flat
    }
    
    func nestTimeSortedCommentArray(of flatComments: [ RealmComment ]){
        //TODO: really bad efficency fix later. Should be find for small comment numbers
        for comment in flatComments {
            for possibleChild in flatComments {
                if let parent_id = possibleChild.parent_id.value {
                    if parent_id == comment.id {
                        comment.childComments.append(possibleChild)
                    }
                }
            }
        }
    }
    
    func getChildComments(for comments: [ RealmComment ]) -> [ RealmComment ] {
        return []
    }
    
    func formList(from commentList: List<RealmComment>) -> [ RealmComment ] {
        var result: [ RealmComment ] = []
        for i in 0..<commentList.count {
            result.append(commentList[i])
        }
        return result
    }
    
    func setActivityIndicatorState(loading: Bool) {
        /**
        if loading {
            postImage.image = nil
            postImage.backgroundColor = UIColor.black
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
         **/
    }
    
    func onToggleSave(on: Bool, for post: Post) {
        print("onToggleSave on:\(on)")
        dataDelegate.onSaveAciton(saved: on, for: post)
    }
    func onToggleLike(on: Bool, for post: Post) {
        let action: VoteAction = on ? .likeOn : .likeOff
        dataDelegate.onVoteAciton(action: action, for: post)
        
        if on {
            dislikeButton.setState(on: false)
        }
        self.postContainer.layoutSubviews()
    }
    func onToggleDislike(on: Bool, for post: Post) {
        let action: VoteAction = on ? .dislikeOn : .dislikeOff
        dataDelegate.onVoteAciton(action: action, for: post)
        if on {
            likeButton.setState(on: false)
        }
    }
    func addTap() {
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
        optionsButton.isUserInteractionEnabled = true
        optionsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPostOptionsTap)))
    }
    

    @objc func shareTap() {
        guard
            let msg = self.shareMessage,
            let url = self.shareUrl else { return }
        delegate.share(msg: msg, url: url, sourceView: shareButton)
    }
    
    @objc func backButtonTapped() {
        delegate.onBackPressed()
    }
    
    private func whiteBackArrow() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 44, height: 44)
        menuBtn.imageEdgeInsets = UIEdgeInsetsMake(14, 0, 14, 26)
        menuBtn.setImage(UIImage(named:"whiteBackArrow"), for: .normal)
        menuBtn.addTarget(self, action: #selector(backButtonTapped), for: UIControlEvents.touchUpInside)
        menuBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 44)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    func popAlertController()
    {
        let alertController : UIAlertController = UIAlertController(title: "To Comment You Need to Sign Up", message: "It only takes a few seconds...", preferredStyle: UIAlertControllerStyle.alert)
        let alertActionSignup : UIAlertAction = UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.default, handler: { _ in
            self.delegate.showLoginSignUp()
        })
        let alertActionStayHere : UIAlertAction = UIAlertAction(title: "Stay Here", style: UIAlertActionStyle.default, handler: { _ in
            self.commentText.resignFirstResponder()
        })
        alertController.addAction(alertActionSignup)
        alertController.addAction(alertActionStayHere)
        present(alertController, animated: true, completion: nil)
    }
    
    private func dynamicKeyboardViewPosition() {
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(notification:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }
    
    @objc func onPostOptionsTap() {
        PostStateManager.instance.handleSnippetMenuButtonClicked(snippetID: post.id, viewController: self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let _ = notification.userInfo {
            self.view.layoutIfNeeded()
            var animationDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
                var info = notification.userInfo!
                var keyboardHeight : CGFloat = ((info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height)!
                
                if #available(iOS 11.0, *)
                {
                    let bottomInset = self.view.safeAreaInsets.bottom
                    keyboardHeight -= bottomInset
                }
                let tabBarController = self.tabBarController
                let tabBarHeight = (tabBarController == nil ? 0 : tabBarController!.tabBar.frame.size.height)
                self.bottomConstraint.constant = keyboardHeight - tabBarHeight //Tab bar height, quick fix
            }, completion: { [weak self] completed in
                guard let s = self else { return }
                s.scrollToComment(scrollComment: s.replyComment, type: .bottom)
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.replyComment = nil
        if let info = notification.userInfo {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.bottomConstraint.constant = 0
            }, completion: { [weak self] completed in
                guard let s = self else { return }
                s.scrollToComment(scrollComment: s.replyComment, type: .top)
            })
        }
    }
    
    @objc func keyboardDidChangeFrame(notification: NSNotification) {
        if let info = notification.userInfo {
            var keyboardHeight : CGFloat = ((info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height)!
            if #available(iOS 11.0, *)
            {
                let bottomInset = self.view.safeAreaInsets.bottom
                keyboardHeight -= bottomInset
            }
            self.bottomConstraint.constant = keyboardHeight - 83 //Tab bar height, quick fix
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    func setUpWriteBox() {
        let writeCommentRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(interceptWriteBoxTap))
        writeCommentRecognizer.delegate = self
        commentText.isUserInteractionEnabled = true
        commentText.addGestureRecognizer(writeCommentRecognizer)
    }
    
    func scrollToHeader() {
        self.tableView.scrollRectToVisible(CGRect(x: 0, y: numberOfCommentsLabel.frame.maxY + 5, width: 1, height: 1), animated: true)
    }
    
    func scrollToComment(scrollComment: RealmComment?, type: UITableViewScrollPosition) {
        var scrollIndex: Int?
        if let target = scrollComment {
            if let comments = self.commentArray {
                let index = comments.index { (cmt) -> Bool in
                    return cmt.id == target.id
                }
                if index != nil {
                    scrollIndex = index!
                }
            }
        } else {
            if let c = self.commentArray {
                if c.count > 0 {
                    scrollIndex = 0
                }
            }
        }
        if let i = scrollIndex {
            tableView.scrollToRow(at: IndexPath(row: i, section: 0), at: type, animated: true)
        } else {
            scrollToHeader()
        }
    }
    
    @objc func interceptWriteBoxTap() {
        if (SessionManager.instance.loggedIn) {
            if !commentText.isFirstResponder {
                commentText.becomeFirstResponder()
            }
        } else {
            popAlertController()
        }
    }
    
    @objc func onSend() {
        guard let body = commentText.text else { return }
        if body.count == 0 {
            return
        }
        delegate.postComment(for: self.post, with: body, parent: self.replyComment)
        commentText.resignFirstResponder()
        commentText.text = ""
        replyToLabel.text = ""
        replyComment = nil
        self.toggleReplyStatus(show: false)
    }
    
    @objc func onCancelReply() {
        self.replyComment = nil
        self.replyToLabel.text = ""
        self.toggleReplyStatus(show: false)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
    }
    @IBAction func onKeyboardSend() {
        onSend()
    }
    
    deinit {
        if let t = self.token {
            t.invalidate()
        }
    }
}

extension PostDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CommentCell!
        if let c = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? CommentCell {
            cell = c
        } else {
            cell = CommentCell()
        }
        guard let list = self.commentArray else {
            return cell
        }
        cell.delegate = self
        cell.bind(with: list[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = self.commentArray {
            return array.count
        } else {
            return 0
        }
    }
}

extension PostDetailViewController: CommentCellDelegate {
    func onReplyRequested(for comment: RealmComment) {
        self.replyComment = comment
        if let writer = comment.writer {
            replyToLabel.text = "Replying to \(writer.first_name) \(writer.last_name)"
        } else {
            replyToLabel.text = "Replying"
        }
        self.toggleReplyStatus(show: true)
        if !commentText.isFirstResponder {
            commentText.becomeFirstResponder()
        } else {
            scrollToComment(scrollComment: comment, type: .bottom)
        }
    }
}

extension PostDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }
}
