//
//  PostDetailCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/24/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

enum PostDisplayMode {
    case none
    case showComments
    case startComment
}
class PostDetailCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var viewController: PostDetailCollectionViewController!
    var navigationController: UINavigationController!
    var post: Post!
    var displayMode: PostDisplayMode
    init(navigationController: UINavigationController, post: Post, mode: PostDisplayMode) {
        self.navigationController = navigationController
        self.post = post
        self.displayMode = mode
        
        SnipLoggerRequests.instance.logPostCommentIteraction(postId: post.id, interaction: .opened)
    }
    
    func start() {
        viewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "PostDetailCollectionViewController") as! PostDetailCollectionViewController
        viewController.delegate = self
        viewController.bindData(data: post, displayMode: displayMode)
        navigationController.pushViewController(viewController, animated: true)
    }
    func pushLoginSignUp() {
        let authCoord = AuthCoordinator(presentingViewController: viewController)
        authCoord.delegate = self
        authCoord.start()
    }
}

extension PostDetailCoordinator: PostDetailViewDelegate {
    func deleteComment(comment: RealmComment) {
        SnipRequests.instance.postDeleteComment(comment: comment)
        
        SnipLoggerRequests.instance.logPostCommentIteraction(postId: self.post.id, interaction: .delete)
    }
    
    func editComment(for post: Post, with body: String, of comment: RealmComment) {
        SnipRequests.instance.postCommentEdit(post_id: post.id, comment: comment, newBody: body)
        
        SnipLoggerRequests.instance.logPostCommentIteraction(postId: self.post.id, interaction: .edit)
    }
    
    func openInternalLink(url: URL) {
        AppLinkUtils.resolveAndPushAppLink(link: url.absoluteString, navigationController: self.navigationController)
    }
    
    func showLoginSignUp() {
        pushLoginSignUp()
    }
    
    func postComment(for post: Post, with body: String, parent: RealmComment?) {
        SnipRequests.instance.postCommentToPost(for: post, body: body, parent: parent)
        SnipLoggerRequests.instance.logPostCommentIteraction(postId: self.post.id, interaction: .submit)
    }
    
    func share(msg: String, url: NSURL, sourceView: UIView) {
        let objects = [msg, url] as [ Any ]
        let activityVC = UIActivityViewController(activityItems: objects, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sourceView
        viewController.present(activityVC, animated: true, completion: nil)
        
        SnipLoggerRequests.instance.logPostShared(postId: self.post.id)
    }
    
    func onBackPressed() {
        viewController = nil
        navigationController.popViewController(animated: true)
        navigationController = nil
        post = nil
    }
}

extension PostDetailCoordinator: AuthCoordinatorDelegate {
    func onSuccessfulSignup(profile: User) {
        // pass
    }
    
    func onCancel() {
        //guard let vc = viewController, let input = vc.commentText else { return }
        //input.resignFirstResponder()
    }
    
    func onSuccessfulLogin(profile: User) {
        // pass
    }
}
