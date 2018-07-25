//
//  PostDetailCollectionViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/23/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import IGListKit
import RealmSwift

enum CommentInputMode {
    case reply(parentId: Int)
    case edit(commentId: Int)
    case none
}

protocol PostCommentInteractionDelegete: class {
    func share(msg: String, url: NSURL, sourceView: UIView)
    func postComment(postId: Int, with body: String, parentId: Int?)
    func editComment(postId: Int, with body: String, commentId: Int)
    func deleteComment(commentId: Int)
    func showLoginSignUp()
    func openInternalLink(url: URL)
}

class PostDetailCollectionViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    var model: Post?
    var data: [ListDiffable] = []
    var sectionController: PostDetailSectionController?
    
    var collectionView: UICollectionView!
    var adapter: ListAdapter?
    var notificationToken: NotificationToken?
    var displayMode: PostDisplayMode = .none
    
    var loggedInUser: User? = nil
    
    weak var delegate: PostCommentInteractionDelegete?
    
    var statusBarLabel: UILabel!
    var commentTextField: UITextField!
    var commentSendButton: UIButton!
    var inputContainer: UIView!
    var statusBarCloseButton: UIButton!
    var statusBarContainer: UIView!
    var statusBarConstraint: NSLayoutConstraint!
    
    var inputMode: CommentInputMode = .none
    var deleteComment: Int?
    
    var inputBoxBottomConstraint: NSLayoutConstraint!
    
    lazy var inputBox: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.white
        container.translatesAutoresizingMaskIntoConstraints = false
        let statusBar = UIView()
        self.statusBarContainer = statusBar
        statusBar.translatesAutoresizingMaskIntoConstraints = false
        statusBar.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        let inputContainer = UIView()
        self.inputContainer = inputContainer
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let textField = UITextField()
        textField.placeholder = "Write a comment..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.commentTextField = textField
        textField.font = UIFont.lato(size: 16)
        textField.textColor = UIColor(white: 0.2, alpha: 1.0)
        textField.autocapitalizationType = .sentences
        textField.autocorrectionType = .default
        textField.keyboardAppearance = .light
        textField.returnKeyType = .send
        textField.delegate = self
        
        let sendButton = UIButton(type: .custom)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.commentSendButton = sendButton
        sendButton.setTitle("", for: .normal)
        sendButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        sendButton.setImage(#imageLiteral(resourceName: "postIconEnabled"), for: .normal)
        sendButton.addTarget(self, action: #selector(onSend), for: .touchUpInside)
        
        inputContainer.addSubview(textField)
        textField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16).isActive = true
        textField.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 0).isActive = true
        textField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 0).isActive = true
        
        textField.isUserInteractionEnabled = true
        textField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(commentTextFieldTap)))
        
        inputContainer.addSubview(sendButton)
        sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: 0).isActive = true
        sendButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 5).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16).isActive = true
        
        let statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusBarLabel = statusLabel
        statusLabel.font = UIFont.lato(size: 13)
        statusLabel.textColor = UIColor(white: 0.2, alpha: 1.0)
        
        let closeStatusButton = UIButton(type: .custom)
        closeStatusButton.translatesAutoresizingMaskIntoConstraints = false
        self.statusBarCloseButton = closeStatusButton
        closeStatusButton.setTitle("", for: .normal)
        closeStatusButton.setImage(#imageLiteral(resourceName: "blackCross"), for: .normal)
        closeStatusButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        closeStatusButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        closeStatusButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        closeStatusButton.addTarget(self, action: #selector(cancelInputMode), for: .touchUpInside)
        
        statusBar.heightAnchor.constraint(equalToConstant: 32).isActive = true
        statusBar.addSubview(statusLabel)
        statusBar.addSubview(closeStatusButton)
        
        statusLabel.leadingAnchor.constraint(equalTo: statusBar.leadingAnchor, constant: 16).isActive = true
        statusLabel.centerYAnchor.constraint(equalTo: statusBar.centerYAnchor).isActive = true
        statusLabel.text = "Replying to CJ Zeiger"
        closeStatusButton.trailingAnchor.constraint(equalTo: statusBar.trailingAnchor, constant: -16).isActive = true
        closeStatusButton.centerYAnchor.constraint(equalTo: statusBar.centerYAnchor).isActive = true
        
        container.addSubview(inputContainer)
        container.addSubview(statusBar)
        
        inputContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        inputContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        inputContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        
        statusBar.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        self.statusBarConstraint = container.topAnchor.constraint(equalTo: inputContainer.topAnchor)
        self.statusBarConstraint.isActive = true
        statusBar.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        
        inputContainer.topAnchor.constraint(equalTo: statusBar.bottomAnchor, constant: 0).isActive = true
        
        
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        container.addSubview(divider)
        divider.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        divider.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        return container
    }()
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result: [ListDiffable] = []
        if let viewModel = model?.asDetailViewModel(activeUserUsername: self.loggedInUser?.username ?? "") {
            result.append(viewModel)
        }
        
        self.data = result
        return result
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let controller = PostDetailSectionController()
        self.sectionController = controller
        controller.delegate = self
        controller.commentDelegate = self
        return controller
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    func performUpdates() {
        if let a = self.adapter {
            a.performUpdates(animated: false, completion: nil)
        }
    }
    
    func bindData(data: Post, displayMode: PostDisplayMode) {
        self.displayMode = displayMode
        self.model = data
        startNotification()
        performUpdates()
    }
    
    private func bindView() {
        performUpdates()
    }
    
    override func viewDidLoad() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        let updater = ListAdapterUpdater()
        let adapter = ListAdapter(updater: updater, viewController: self)
        self.view.addSubview(collectionView)
        let g = self.view.safeAreaLayoutGuide
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: g.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: g.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: g.trailingAnchor).isActive = true
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        
        self.collectionView = collectionView
        self.adapter = adapter
        
        collectionView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.view.addSubview(self.inputBox)
        self.inputBox.translatesAutoresizingMaskIntoConstraints = false
        self.inputBox.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 0).isActive = true
        self.inputBoxBottomConstraint = g.bottomAnchor.constraint(equalTo: inputBox.bottomAnchor, constant: 0)
        self.inputBoxBottomConstraint.isActive = true
        self.inputBox.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: 0).isActive = true
        self.inputBox.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        setStatusBarVisibility(visisble: false)
        
        if SessionManager.instance.loggedIn, let username = SessionManager.instance.currentLoginUsername {
            let realm = RealmManager.instance.getRealm()
            if let user = realm.object(ofType: User.self, forPrimaryKey: username) {
                self.loggedInUser = user
            }
        }
        self.bindView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //collectionView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startNotification()
        self.registerForKeyboardUpdates()
        if (self.isBeingPresented || self.isMovingToParentViewController) {
            switch self.displayMode {
            case .showComments:
                if self.data.count > 0 {
                    self.scrollToFirstComment()
                }
            case .startComment:
                if self.data.count > 0 {
                    self.scrollToFirstComment()
                }
                self.commentTextFieldTap()
            default:
                break
            }
        }
    }
    
    private func scrollToFirstComment() {
        if self.data.count > 0, let controller = self.sectionController {
            controller.scrollToComment(index: 0, scrollPosition: .bottom, andimated: true)
        }
    }
    
    private func scrollToComment(commentId: Int, scrollPosition: UICollectionViewScrollPosition) {
        if self.data.count > 0, let controller = self.sectionController {
            controller.scrollToCommentId(commentId: commentId, scrollPosition: .bottom, andimated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopNotification()
        self.unregisterForKeyboardUpdates()
    }
    
    private func startNotification() {
        guard let model = self.model, self.notificationToken == nil else {
            // Already subscribed no bound model
            return
        }
        
        self.notificationToken = model.comments.observe({ (change) in
            self.performUpdates()
        })
    }
    
    private func stopNotification() {
        if let token = self.notificationToken {
            token.invalidate()
            self.notificationToken = nil
        }
    }
    
    private func showLoginAlert() {
        let alertController : UIAlertController = UIAlertController(title: "To Comment You Need to Sign Up", message: "It only takes a few seconds...", preferredStyle: UIAlertControllerStyle.alert)
        let alertActionSignup : UIAlertAction = UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.default, handler: { _ in
            self.delegate?.showLoginSignUp()
        })
        let alertActionStayHere : UIAlertAction = UIAlertAction(title: "Stay Here", style: UIAlertActionStyle.default, handler: { _ in
            self.commentTextField.resignFirstResponder()
        })
        alertController.addAction(alertActionSignup)
        alertController.addAction(alertActionStayHere)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func commentTextFieldTap() {
        if (SessionManager.instance.loggedIn) {
            if !commentTextField.isFirstResponder {
                commentTextField.becomeFirstResponder()
            }
        } else {
            showLoginAlert()
        }
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
                self.inputBoxBottomConstraint.constant = keyboardHeight - tabBarHeight
                //self.bottomConstraint.constant = keyboardHeight - tabBarHeight //Tab bar height, quick fix
            }, completion: { [unowned self] completed in
                switch self.inputMode {
                case .none:
                    self.scrollToFirstComment()
                case .reply(let replyCommentId):
                    self.scrollToComment(commentId: replyCommentId, scrollPosition: .bottom)
                case .edit(let commentId):
                    self.scrollToComment(commentId: commentId, scrollPosition: .bottom)
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
                self.inputBoxBottomConstraint.constant = 0
            })
        }
    }
    
    func setStatusBarVisibility(visisble: Bool) {
        self.statusBarConstraint.isActive = false
        self.statusBarConstraint = self.inputBox.topAnchor.constraint(equalTo: (visisble ? self.statusBarContainer.topAnchor : self.inputContainer.topAnchor))
        self.statusBarConstraint.isActive = true
        self.statusBarContainer.isHidden = !visisble
    }
    
    func showDeleteConfirmationDialog(commentId: Int) {
        self.deleteComment = commentId
        let alert = UIAlertController(title: "Deleting Comment", message: "Are you sure you want to delete this comment?", preferredStyle: .actionSheet)
        let alertYesAction = UIAlertAction(title: "Delete", style: .destructive, handler: self.completeDeleteAction)
        let alertNoAction = UIAlertAction(title: "Cancel", style: .cancel, handler: self.cancelDeleteAction)
        
        alert.addAction(alertYesAction)
        alert.addAction(alertNoAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func completeDeleteAction(alert: UIAlertAction) {
        guard let deleteComment = self.deleteComment else { return }
        switch self.inputMode {
        case .edit(let commentId):
            if deleteComment == commentId {
                cancelInputMode()
            }
        case .reply(let parentId):
            if deleteComment == parentId {
                cancelInputMode()
            }
        default:
            break
        }
        delegate?.deleteComment(commentId: deleteComment)
        self.deleteComment = nil
    }
    
    func cancelDeleteAction(alert: UIAlertAction) {
        self.deleteComment = nil
    }
    
    @objc func onSend() {
        if !SessionManager.instance.loggedIn {
            if self.commentTextField.isFirstResponder {
                self.commentTextField.resignFirstResponder()
            }
            showLoginAlert()
            return
        }
        
        guard let body = commentTextField.text, let model = self.model else { return }
        if body.count == 0 {
            return
        }
        switch self.inputMode {
        case .none:
            delegate?.postComment(postId: model.id, with: body, parentId: nil)
        case .reply(let parentCommentId):
            delegate?.postComment(postId: model.id, with: body, parentId: parentCommentId)
        case .edit(let editCommentId):
            delegate?.editComment(postId: model.id, with: body, commentId: editCommentId)
        }
        
        commentTextField.resignFirstResponder()
        commentTextField.text = ""
        statusBarLabel.text = ""
        self.inputMode = .none
        self.setStatusBarVisibility(visisble: false)
    }
    
    @objc func cancelInputMode() {
        self.inputMode = .none
        self.commentTextField.text = ""
        setStatusBarVisibility(visisble: false)
    }
    
    deinit {
        stopNotification()
    }
}

extension PostDetailCollectionViewController: PostInteractionDelegate {
    func showExpandedImage(postId: Int) {
        let realm = RealmManager.instance.getMemRealm()
        guard let post = realm.object(ofType: Post.self, forPrimaryKey: postId) else { return }
        ExpandedImageViewController.showExpandedImage(for: post, presentingVC: self)
    }
    
    func setExpanded(postId: Int, _ expanded: Bool) {
        // pass
    }
    
    func showCategoryPosts(categoryName: String) {
        // pass
    }
    
    func showPostDetail(postId: Int, startComment: Bool) {
        // pass 
    }
    
    func showWritersPosts(writerUserName: String) {
        // pass
    }
    
    func savePost(postId: Int) {
        // pass
    }
    
    func setVoteValue(postId: Int, value: Double) {
        guard let post = RealmManager.instance.getMemRealm().object(ofType: Post.self, forPrimaryKey: postId) else { return }
        PostStateManager.instance.handleVoteAction(newVoteValue: value, post: post)
    }
    
    func sharePost(postTitle: String, postUrlString: String, sourceView: UIView) {
        guard let url = URL(string: postUrlString) else { return }
        delegate?.share(msg: postTitle, url: url as NSURL, sourceView: sourceView)
    }
    
    func showPostOptions(postId: Int) {
        PostStateManager.instance.handleSnippetMenuButtonClicked(snippetID: postId, viewController: self)
    }
}

extension PostDetailCollectionViewController: CommentCollectionDelegate {
    func replyToComment(parentCommentId: Int, replyAuthorName: String) {
        self.inputMode = .reply(parentId: parentCommentId)
        self.statusBarLabel.text = "Replying to \(replyAuthorName)"
        setStatusBarVisibility(visisble: true)
        
        if !commentTextField.isFirstResponder {
            commentTextField.becomeFirstResponder()
        }
        
        self.commentTextField.selectedTextRange = self.commentTextField.textRange(from: self.commentTextField.endOfDocument, to: self.commentTextField.endOfDocument)
    }
    
    func editComment(commentId: Int, commentBody: String) {
        self.inputMode = .edit(commentId: commentId)
        self.statusBarLabel.text = "Editing Comment"
        self.commentTextField.text = commentBody
        setStatusBarVisibility(visisble: true)
        
        if !commentTextField.isFirstResponder {
            commentTextField.becomeFirstResponder()
        }
    }
    
    func deleteComment(commentId: Int) {
        self.showDeleteConfirmationDialog(commentId: commentId)
    }
}

extension PostDetailCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onSend()
        return true
    }
}
