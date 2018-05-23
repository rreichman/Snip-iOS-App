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
        
    }
    
    private func postVoteState(vote: VoteState, for post: Post) {
        var isLiked: Bool!
        var isDisliked: Bool!
        var vote_val: Double!
        switch vote {
        case .none:
            vote_val = 0.0
            isLiked = false
            isDisliked = false
        case .like:
            vote_val = 1.0
            isLiked = true
            isDisliked = false
        case.dislike:
            vote_val = -1.0
            isDisliked = true
            isLiked = false
        case.value(let value):
            vote_val = value
            isLiked = false
            isDisliked = false
        }
        
        let realm = RealmManager.instance.getMemRealm()
        try! realm.write {
            post.voteValue = vote_val
            post.isDisliked = isDisliked
            post.isLiked = isLiked
        }
        SnipRequests.instance.postVoteState(post_id: post.id, vote_val: vote_val)
    }
}

extension PostStateManager: SnipCellDataDelegate {
    func writeVoteState(to: VoteState, for post: Post) {
        postVoteState(vote: to, for: post)
    }
    
    func writeSaveState(saved: Bool, for post: Post) {
        postSavePost(saved: saved, for: post)
    }
    
    
}
