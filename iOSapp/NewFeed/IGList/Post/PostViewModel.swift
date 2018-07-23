//
//  PostViewModel.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/19/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import IGListKit

final class PostViewModel: ListDiffable {
    
    
    // Properites
    let id: Int
    let title: String
    let subhead: NSAttributedString
    let body: NSAttributedString
    let authorName: String
    let dateString: String
    let imageUrl: String
    let urlString: String
    let numberOfComments: Int
    let timestamp: String
    let authorUsername: String
    
    //View State
    let saved: Bool
    let voteValue: Double
    let expanded: Bool
    
    
    init(id: Int, title: String, subhead: NSAttributedString, body: NSAttributedString, authorName: String, dateString: String, saved: Bool, imageUrl: String, voteValue: Double, urlString: String, numberOfComments: Int, timestamp: String, expanded: Bool = false, authorUsername: String) {
        self.id = id
        self.title = title
        self.subhead = subhead
        self.body = body
        self.authorName = authorName
        self.dateString = dateString
        self.saved = saved
        self.imageUrl = imageUrl
        self.voteValue = voteValue
        self.urlString = urlString
        self.numberOfComments = numberOfComments
        self.timestamp = timestamp
        self.expanded = expanded
        self.authorUsername = authorUsername
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? PostViewModel else { return false }
        return true
    }
    
    
}
