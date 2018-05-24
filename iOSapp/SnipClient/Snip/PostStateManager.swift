//
//  PostStateManager.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift


class PostStateManager {
    static let instance: PostStateManager = PostStateManager()
    
    private func postSavePost(saved: Bool, for post: Post) {
        let realm = RealmManager.instance.getMemRealm()
        try! realm.write {
            post.saved = saved
        }
        SnipRequests.instance.postSaveState(post_id: post.id)
    }
    
    private func postVoteState(action: VoteAction, for post: Post) {
        let vote_val = handleVoteAction(action: action, post: post)
        SnipRequests.instance.postVoteState(post_id: post.id, vote_val: vote_val)
    }
    
    func handleVoteAction(action: VoteAction, post: Post) -> Double {
        var like: Bool = post.isLiked
        var dislike: Bool = post.isDisliked
        switch action {
        case .likeOn:
            dislike = false
            like = true
        case .likeOff:
            like = false
        case .dislikeOn:
            dislike = true
            like = false
        case .dislikeOff:
            dislike = false
        }
        
        var vote_val: Double
        if !like && !dislike {
            vote_val = 0.0
        } else if like {
            vote_val = 1.0
        } else {
            vote_val = -1.0
        }
        
        let realm = RealmManager.instance.getMemRealm()
        try! realm.write {
            post.isLiked = like
            post.isDisliked = dislike
            post.voteValue = vote_val
        }
        return vote_val
    }
    
    func sendReportToServer(snippetID: Int, reasons: String)
    {
        let _ : ReportInfo = ReportInfo(snippetID: snippetID, reasons: reasons)
        //testSendReportToServer(reportParams: reportInfo)
    }
    
  
    
    func handleSnippetMenuButtonClicked(snippetID : Int, viewController : UIViewController)
    {
        print("test button")
        let alertController = UIAlertController()
        
        let spamAction = UIAlertAction(title: "Report Spam", style: .default, handler: { [snippetID] alert in
            self.sendReportToServer(snippetID: snippetID, reasons: "spam")
        })
        let notOriginalContentAction = UIAlertAction(title: "Content Isn't Original", style: .default, handler: { [snippetID] alert in
            self.sendReportToServer(snippetID: snippetID, reasons: "contentnotoriginal")
        })
        let notOriginalPhotoAction = UIAlertAction(title: "Photo Isn't Original", style: .default, handler: { [snippetID] alert in
            self.sendReportToServer(snippetID: snippetID, reasons: "photonotoriginal")
        })
        let harmfulOrOffendingAction = UIAlertAction(title: "Post is Harmful or Offending", style: .default, handler: { [snippetID] alert in
            self.sendReportToServer(snippetID: snippetID, reasons: "harmfuloroffending")
        })
        let unwantedAdvertisingAction = UIAlertAction(title: "Post is Unwanted Advertising", style: .default, handler: { [snippetID] alert in
            self.sendReportToServer(snippetID: snippetID, reasons: "unwantedadvertising")
        })
        let dontLikeThisAction = UIAlertAction(title: "I Don't Like This", style: .default, handler: { [snippetID] alert in
            self.sendReportToServer(snippetID: snippetID, reasons: "idontlikethis")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(spamAction)
        alertController.addAction(notOriginalContentAction)
        alertController.addAction(notOriginalPhotoAction)
        alertController.addAction(harmfulOrOffendingAction)
        alertController.addAction(unwantedAdvertisingAction)
        alertController.addAction(dontLikeThisAction)
        alertController.addAction(cancelAction)
        
        //alertController.popoverPresentationController?.sourceView = viewController.view
        
        viewController.present(alertController, animated: true)
    }
}

extension PostStateManager: SnipCellDataDelegate {
    func onVoteAciton(action: VoteAction, for post: Post) {
        postVoteState(action: action, for: post)
    }
    
    func onSaveAciton(saved: Bool, for post: Post) {
        postSavePost(saved: saved, for: post)
    }
    
    
}
