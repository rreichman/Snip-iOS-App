//
//  PostExpandedViewModel.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/23/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import IGListKit

class PostExpandedViewModel: ListDiffable {
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
    let authorUsername: String
    let authorAvatarUrl: String
    let authorInitials: String
    
    //View State
    let saved: Bool
    let voteValue: Double
    
    
    init(id: Int, title: String, subhead: NSAttributedString, body: NSAttributedString, authorName: String, dateString: String, saved: Bool, imageUrl: String, voteValue: Double, urlString: String, numberOfComments: Int,  authorUsername: String, authorAvatarUrl: String, authorInitials: String) {
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
        self.authorUsername = authorUsername
        self.authorAvatarUrl = authorAvatarUrl
        self.authorInitials = authorInitials
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "\(id) psot-expanded" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? PostExpandedViewModel else { return false }
        return id == obj.id && voteValue == obj.voteValue && numberOfComments == obj.numberOfComments
    }
}
