//
//  PostHeaderViewModel.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/19/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import IGListKit

class PostHeaderViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return "\(id) header" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? PostHeaderViewModel else { return false }
        return saved == obj.saved && imageUrl == obj.imageUrl && expanded == self.expanded
    }
    
    let id: Int
    let title: String
    let subheadline: NSAttributedString
    let authorName: String
    let dateString: String
    let saved: Bool
    let imageUrl: String
    let expanded: Bool
    let authorUsername: String
    let postUrl: String
    
    init(id: Int, title: String, subheadline: NSAttributedString, authorName: String, dateString: String, saved: Bool, imageUrl: String, expanded: Bool, authorUsername: String, postUrl: String) {
        self.id = id
        self.title = title
        self.subheadline = subheadline
        self.authorName = authorName
        self.dateString = dateString
        self.saved = saved
        self.imageUrl = imageUrl
        self.expanded = expanded
        self.authorUsername = authorUsername
        self.postUrl = postUrl
    }
}
