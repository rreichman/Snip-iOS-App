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
    
    private func postVoteState(newVoteValue: Double, for post: Post) {
        handleVoteAction(newVoteValue: newVoteValue, post: post)
        SnipRequests.instance.postVoteState(post_id: post.id, vote_val: newVoteValue)
    }
    
    func handleVoteAction(newVoteValue: Double, post: Post) {
        let realm = RealmManager.instance.getMemRealm()
        try! realm.write {
            post.voteValue = newVoteValue
        }
    }
    
    func sendReportToServer(snippetID: Int, reasons: String)
    {
        SnipRequests.instance.postReport(post_id: snippetID, reason: reasons, param1: "")
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
    func onVoteAciton(newVoteValue: Double, for post: Post) {
        postVoteState(newVoteValue: newVoteValue, for: post)
    }
    
    func onSaveAciton(saved: Bool, for post: Post) {
        postSavePost(saved: saved, for: post)
    }
    
    
}
