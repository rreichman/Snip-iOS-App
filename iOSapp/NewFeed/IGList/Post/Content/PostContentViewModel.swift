//
//  PostContentViewModel.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/19/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import IGListKit

class PostContentViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return "\(id) content" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? PostContentViewModel else { return false }
        return expanded == obj.expanded && voteValue == obj.voteValue && numberOfComments == obj.numberOfComments && body.string == obj.body.string
    }
    
    let id: Int
    let body: NSAttributedString
    let numberOfComments: Int
    let postUrl: String
    let voteValue: Double
    let expanded: Bool
    let authorUsername: String
    let title: String
    
    
    init(id: Int, body: NSAttributedString, numberOfComments: Int, postUrl: String, voteValue: Double, expanded: Bool, authorUsername: String, title: String) {
        self.id = id
        self.body = body
        self.numberOfComments = numberOfComments
        self.postUrl = postUrl
        self.voteValue = voteValue
        self.expanded = expanded
        self.authorUsername = authorUsername
        self.title = title
    }
}
