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


class PostDetailCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    
    var viewController: PostDetailViewController!
    var navigationController: UINavigationController!
    var post: Post!
    init(navigationController: UINavigationController, post: Post) {
        self.navigationController = navigationController
        self.post = post
    }
    
    func start() {
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
        viewController.delegate = self
        viewController.bind(data: post)
        navigationController.pushViewController(viewController, animated: true)
    }
    func pushLoginSignUp() {
        let authCoord = AuthCoordinator(presentingViewController: viewController)
        authCoord.delegate = self
        authCoord.start()
    }
}

extension PostDetailCoordinator: PostDetailViewDelegate {
    func showLoginSignUp() {
        pushLoginSignUp()
    }
    
    func postComment(for post: Post, with body: String, parent: RealmComment?) {
        SnipRequests.instance.postCommentToPost(for: post, body: body, parent: parent)
    }
    
    func share(msg: String, url: NSURL, sourceView: UIView) {
        let objects = [msg, url] as [ Any ]
        let activityVC = UIActivityViewController(activityItems: objects, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sourceView
        viewController.present(activityVC, animated: true, completion: nil)
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
        guard let vc = viewController, let input = vc.commentText else { return }
        input.resignFirstResponder()
    }
    
    func onSuccessfulLogin(profile: User) {
        // pass
    }
    
    
}
