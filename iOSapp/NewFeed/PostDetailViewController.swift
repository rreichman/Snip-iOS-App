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
import Nuke

enum CommentInputMode {
    case reply
    case edit
    case none
}

protocol PostDetailViewDelegate: class {
    func share(msg: String, url: NSURL, sourceView: UIView)
    func postComment(for post: Post, with body: String, parent: RealmComment?)
    func editComment(for post: Post, with body: String, of comment: RealmComment)
    func deleteComment(comment: RealmComment)
    func onBackPressed()
    func showLoginSignUp()
    func openInternalLink(url: URL)
}

class PostDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var authorAvatarImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var bodyTextView: UITextViewFixed!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var optionsButton: UIImageView!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var shortAuthorLabel: UILabel!
    @IBOutlet var writeBoxContainer: UIView!
    @IBOutlet var postCommentButton: UIButton!
    @IBOutlet var numberOfCommentsLabel: UILabel!
    @IBOutlet var commentText: UITextField!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var statusContainer: UIView!
    @IBOutlet var cancelReplyButton: UIButton!
    @IBOutlet var inputStatusLabel: UILabel!
    
    @IBOutlet var headerContainerView: UIView!
    @IBOutlet var voteControl: VoteControl!
    @IBOutlet var writeBoxDivider: UIView!
    var delegate: PostDetailViewDelegate!
    var dataDelegate: SnipCellDataDelegate!
    var dateFormatter: DateFormatter = DateFormatter()
    var shareMessage: String?
    var shareUrl: NSURL?
    
    var post: Post!
    var commentArray: [ RealmComment ]?
    var token: NotificationToken?
    var postImageToken: NotificationToken?
    var topConstraint: NSLayoutConstraint!
    var mode: PostDisplayMode?
    var currentUser: User?
    
    //Input mode state, depends on what the text input will do on send
    var replyComment: RealmComment?
    var editComment: RealmComment?
    var deleteComment: RealmComment?
    var inputMode: CommentInputMode = .none
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        voteControl.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        dataDelegate = PostStateManager.instance
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setUpWriteBox()
        
        setupHeaderView()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        bodyTextView.isScrollEnabled = false
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.delegate = self
        
        postCommentButton.addTarget(self, action: #selector(onSend), for: .touchUpInside)
        cancelReplyButton.addTarget(self, action: #selector(onCancelInputMode), for: .touchUpInside)
        addTap()
        
        topConstraint = writeBoxDivider.bottomAnchor.constraint(equalTo: commentText.topAnchor)
        topConstraint.isActive = true
        
        postImage.layer.cornerRadius = 10
        
        
        if SessionManager.instance.loggedIn && SessionManager.instance.currentLoginUsername != nil {
            let realm = RealmManager.instance.getRealm()
            self.currentUser = realm.object(ofType: User.self, forPrimaryKey: SessionManager.instance.currentLoginUsername!)
        }
        
        self.bindViews(data: self.post)
    }
    
    func setupHeaderView() {
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        let headerView = tableView.tableHeaderView!
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        /**
        headerContainerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        headerContainerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        headerContainerView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        **/
        tableView.tableHeaderView = headerView
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //print("PostDetailViewController.viewDidLayoutSubviews()")
        sizeHeaderToFit()
    }
    
    func sizeHeaderToFit() {
        //print("PostDetailViewController.sizeHeaderToFit()")
        let headerView = tableView.tableHeaderView!
        
        //print("PostDetailViewController setting needs layout flag on the header view, calling layoutIfNeeded()")
        //print("bodyText intrinsic: \(bodyTextView.intrinsicContentSize) headerView intrinsic: \(headerView.intrinsicContentSize)")
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        //print("bodyText intrinsic: \(bodyTextView.intrinsicContentSize) headerView intrinsic: \(headerView.intrinsicContentSize)")
        //print("PostDetailViewController Done layingout the header view")
        
        /**
        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        print("Calculating correct height using systemLayoutSizeFitting(UILayoutFittingCompressedSize).height, result is \(height)")
        
        let actual_header_height = headerView.frame.size.height
        let contentSize = bodyTextView.contentSize
        let frame_size = bodyTextView.frame.size.height
        let intrinsicContentSize = bodyTextView.intrinsicContentSize
        let post = self.post
        let text = bodyTextView.text
 
        var current_frame = headerView.frame
        var size_that_fits = headerView.sizeThatFits(CGSize(width: current_frame.width, height: CGFloat.greatestFiniteMagnitude))
        print("Size that fits: \(size_that_fits)")
        current_frame.size.height = size_that_fits.height
        headerView.frame = current_fram
        **/
 
        tableView.tableHeaderView = headerView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.registerForKeyboardUpdates()
        if (self.isBeingPresented || self.isMovingToParentViewController) {
            //print("PostDetailView is appearing for the first time")
            guard let m = self.mode else { return }
            switch m {
            case .showComments:
                if let comments = self.commentArray {
                    if comments.count > 0 {
                        self.scrollToFirstComment()
                    }
                }
            case .startComment:
                if let comments = self.commentArray {
                    if comments.count > 0 {
                        self.scrollToFirstComment()
                    }
                }
                commentText.becomeFirstResponder()
            default:
                break
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.unregisterForKeyboardUpdates()
    }
    
    func setUpWriteBox() {
        let writeCommentRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(interceptWriteBoxTap))
        writeCommentRecognizer.delegate = self
        commentText.isUserInteractionEnabled = true
        commentText.addGestureRecognizer(writeCommentRecognizer)
    }
    
    func toggleInputModeStatusView(show: Bool) {
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
    
    func bind(data: Post, mode: PostDisplayMode) {
        self.post = data
        self.mode = mode
        subscribeToRealmNotifications(data: data)
        bindViews(data: data)
        
    }
    
    func subscribeToRealmNotifications(data: Post) {
        if let image = data.image {
            self.postImageToken = image.observe({ [weak self] (change) in
                switch change {
                case .change(let properties):
                    for property in properties {
                        if property.name == "data" && (property.newValue as! Data).count > 0 {
                            guard let s = self, let _ = s.postImage else { return }
                            s.bindImage(imageOpt: image)
                        }
                    }
                default:
                    //do nothing
                    break
                }
            })
        }
        self.token = data.comments.observe({ [weak self](changes) in
            guard let s = self, let _ = s.tableView else { return }
            s.commentArray = s.post.calculateCommentArray()
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
    
    func bindViews(data: Post) {
        //print("PostDetailViewController.bindViews()")
        guard let _ = self.tableView else { return }
        //Binding of elements that will never be hindden
        titleLabel.text = data.headline
        if let auth = data.author {
            authorLabel.text = "\(auth.first_name) \(auth.last_name)"
            shortAuthorLabel.text = auth.initials.uppercased()
            if let avatarURL = URL(string: auth.avatarUrl) {
                Nuke.loadImage(with: avatarURL, into: self.authorAvatarImage)
            } else {
                self.authorAvatarImage.image = nil
            }
            
            /**
            if auth.hasAvatarImageData() {
                authorAvatarImage.isHidden = false
                authorAvatarImage.image = UIImage(data: auth.avatarImage!.data!)
            } else {
                authorAvatarImage.isHidden = true
                authorAvatarImage.image = UIImage()
            }
            **/
        } else {
            authorLabel.text = ""
            shortAuthorLabel.text = ""
            authorAvatarImage.image = nil
        }
        dateLabel.text = data.formattedTimeString()
        bindImage(imageOpt: data.image)
        
        voteControl.bind(voteValue: data.voteValue)
        voteControl.delegate = self
        
        if let richText = data.getAttributedBody() {
            
            //Who knows if anyone really understands how Attributed Text works, it doesnt seem like there is much of anything about it on google
            richText.append(NSAttributedString(string: "\n"))
            let pStyle = NSMutableParagraphStyle()
            pStyle.lineSpacing = 0.0
            pStyle.paragraphSpacing = 12
            pStyle.defaultTabInterval = 36
            pStyle.baseWritingDirection = .leftToRight
            pStyle.minimumLineHeight = 20.0
            
            for source in data.relatedLinks {
                let text = source.title + ", "
                
                let attributes: [NSAttributedStringKey : Any] =
                    [.paragraphStyle: pStyle,
                     .foregroundColor: UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1.0),
                     .font: UIFont.lato(size: 15),
                     .link: URL(string: source.url)!]
                let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
                richText.append(attributedText)
            }
            bodyTextView.attributedText = (data.relatedLinks.count > 0 ? richText.attributedSubstring(from: NSMakeRange(0, richText.length - 2)) : richText)
            //print("PostDetailViewController.bodyTextView.attributedText set")
            //bodyTextView.sizeToFit()
        } else {
            bodyTextView.text = data.text
        }
        bodyTextView.tintColor = UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1.0)
        
        self.shareMessage = "Check out this snippet:\n" + data.headline
        self.shareUrl = NSURL(string: data.fullURL)
        
        let comment_count = data.comments.count
        bindNumberOfCommentsLabel(comment_count: comment_count)
        
        self.commentArray = data.calculateCommentArray()
        bindImage(imageOpt: data.image)
        
    }
    
    func bindNumberOfCommentsLabel(comment_count: Int) {
        let comment_string = "\(comment_count) comment" + (comment_count != 1 ? "s" : "")
        self.numberOfCommentsLabel.text = comment_string
    }
    
    func bindImage(imageOpt: Image?) {
        guard let _ = imageOpt,
            let data = imageOpt?.data else {
                postImage.image = nil
                //setActivityIndicatorState(loading: true)
                return
        }
        
        if data.count < 2 {
            //setActivityIndicatorState(loading: true)
        } else {
            //setActivityIndicatorState(loading: false)
            let ui_image = UIImage(data: data)
            postImage.image = ui_image
            postImage.layer.cornerRadius = 10
            postImage.layer.masksToBounds = true
        }
        //set image to data
    }
    
    func scrollToHeader() {
        self.tableView.scrollRectToVisible(CGRect(x: 0, y: numberOfCommentsLabel.frame.maxY + 5, width: 1, height: 1), animated: true)
    }
    
    func scrollToFirstComment() {
        guard let comments = self.commentArray else { return }
        if tableView.numberOfRows(inSection: 0) == 0 || comments.count == 0 {
            print("attempted to scroll to first comment when it did not exist")
            return
        }
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
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
    
    func addTap() {
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
        optionsButton.isUserInteractionEnabled = true
        optionsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPostOptionsTap)))
    }
    
    func onToggleSave(on: Bool, for post: Post) {
        print("onToggleSave on:\(on)")
        dataDelegate.onSaveAciton(saved: on, for: post)
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
    
    @objc func onPostOptionsTap() {
        PostStateManager.instance.handleSnippetMenuButtonClicked(snippetID: post.id, viewController: self)
        
        SnipLoggerRequests.instance.logPostReadMore(postId: post.id)
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
    
    func showDeleteConfirmationDialog(for comment: RealmComment) {
        self.deleteComment = comment
        let alert = UIAlertController(title: "Deleting Comment", message: "Are you sure you want to delete this comment?", preferredStyle: .actionSheet)
        let alertYesAction = UIAlertAction(title: "Delete", style: .destructive, handler: self.completeDeleteAction)
        let alertNoAction = UIAlertAction(title: "Cancel", style: .cancel, handler: self.cancelDeleteAction)
        
        alert.addAction(alertYesAction)
        alert.addAction(alertNoAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func completeDeleteAction(alert: UIAlertAction) {
        guard let comment = self.deleteComment else { return }
        if comment.id == self.replyComment?.id || comment.id == self.editComment?.id {
            onCancelInputMode()
        }
        delegate.deleteComment(comment: comment)
        self.deleteComment = nil
    }
    
    func cancelDeleteAction(alert: UIAlertAction) {
        self.deleteComment = nil
    }
    
    @objc func onSend() {
        guard let body = commentText.text else { return }
        if body.count == 0 {
            return
        }
        switch self.inputMode {
        case .none:
            delegate.postComment(for: self.post, with: body, parent: nil)
        case .reply:
            delegate.postComment(for: self.post, with: body, parent: self.replyComment)
        case .edit:
            guard let edit_comment = self.editComment else { break }
            delegate.editComment(for: self.post, with: body, of: edit_comment)
        }
        
        commentText.resignFirstResponder()
        commentText.text = ""
        inputStatusLabel.text = ""
        replyComment = nil
        editComment = nil
        self.toggleInputModeStatusView(show: false)
    }
    
    @objc func onCancelInputMode() {
        self.replyComment = nil
        self.editComment = nil
        self.commentText.text = ""
        self.inputStatusLabel.text = ""
        self.inputMode = .none
        self.toggleInputModeStatusView(show: false)
        
        // Not sure if scroll position should be touched here or not
        //tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
    }
    
    @IBAction func onKeyboardSend() {
        onSend()
    }
    
    func popAlertController() {
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
    
    private func registerForKeyboardUpdates() {
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func unregisterForKeyboardUpdates() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print("PostDetailViewController.keyboardWillShow")
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
                switch s.inputMode {
                case .none:
                    s.scrollToFirstComment()
                case .reply:
                    s.scrollToComment(scrollComment: s.replyComment, type: .bottom)
                case .edit:
                    s.scrollToComment(scrollComment: s.editComment, type: .bottom)
                }
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //self.replyComment = nil
        print("PostDetailViewController.keyboardWillHide")
        if let info = notification.userInfo {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.bottomConstraint.constant = 0
            })
        }
    }
    
    deinit {
        if let t = self.token {
            t.invalidate()
        }
        if let t2 = self.postImageToken {
            t2.invalidate()
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
        cell.bind(with: list[indexPath.row], currentUser: self.currentUser)
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
    func onDeleteRequested(for comment: RealmComment) {
        self.showDeleteConfirmationDialog(for: comment)
    }
    
    func onEditRequested(for comment: RealmComment) {
        self.editComment = comment
        self.inputStatusLabel.text = "Editing comment"
        self.commentText.text = comment.body
        self.inputMode = .edit
        self.toggleInputModeStatusView(show: true)
        if !commentText.isFirstResponder {
            commentText.becomeFirstResponder()
        } else {
            scrollToComment(scrollComment: comment, type: .bottom)
        }
        self.commentText.selectedTextRange = self.commentText.textRange(from: self.commentText.endOfDocument, to: self.commentText.endOfDocument)
    }
    
    func onReplyRequested(for comment: RealmComment) {
        self.replyComment = comment
        if let writer = comment.writer {
            inputStatusLabel.text = "Replying to \(writer.first_name) \(writer.last_name)"
        } else {
            inputStatusLabel.text = "Replying"
        }
        self.commentText.text = ""
        self.inputMode = .reply
        self.toggleInputModeStatusView(show: true)
        if !commentText.isFirstResponder {
            commentText.becomeFirstResponder()
        } else {
            scrollToComment(scrollComment: comment, type: .bottom)
        }
    }
}

extension PostDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if AppLinkUtils.shouldOpenLinkInApp(link: URL) {
            print("Opening internal link \(URL.absoluteString)")
            delegate.openInternalLink(url: URL)
        } else {
            UIApplication.shared.open(URL, options: [:])
        }
        
        return false
    }
}

extension PostDetailViewController: VoteControlDelegate {
    func voteValueSet(to value: Double) {
        self.dataDelegate.onVoteAciton(newVoteValue: value, for: self.post)
    }
}
