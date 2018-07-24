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

class PostDetailCollectionViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    var model: Post?
    var data: [ListDiffable] = []
    
    var collectionView: UICollectionView!
    var adapter: ListAdapter?
    var notificationToken: NotificationToken?
    var displayMode: PostDisplayMode = .none
    
    var loggedInUser: User? = nil
    
    weak var delegate: PostDetailViewDelegate?
    
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
        controller.delegate = self
        controller.commentDelegate = self
        return controller
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    func performUpdates() {
        if let a = self.adapter {
            a.performUpdates(animated: true, completion: nil)
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
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        
        self.collectionView = collectionView
        self.adapter = adapter
        
        collectionView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
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
        collectionView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopNotification()
    }
    
    private func startNotification() {
        guard let model = self.model, self.notificationToken == nil else {
            // Already subscribed no bound model
            return
        }
        
        self.notificationToken = model.observe({ (change) in
            self.performUpdates()
        })
    }
    
    private func stopNotification() {
        if let token = self.notificationToken {
            token.invalidate()
            self.notificationToken = nil
        }
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
        
    }
    
    func showWritersPosts(writerUserName: String) {
        
    }
    
    func savePost(postId: Int) {
        
    }
    
    func setVoteValue(postId: Int, value: Double) {
        
    }
    
    func sharePost(postTitle: String, postUrlString: String, sourceView: UIView) {
        
    }
    
    func showPostOptions(postId: Int) {
        
    }
}

extension PostDetailCollectionViewController: CommentCollectionDelegate {
    func replyToComment(parentCommentId: Int) {
        // pass
    }
    
    func editComment(commentId: Int) {
        // pass
    }
    
    func deleteComment(commentId: Int) {
        // pass
    }
    
    
}
