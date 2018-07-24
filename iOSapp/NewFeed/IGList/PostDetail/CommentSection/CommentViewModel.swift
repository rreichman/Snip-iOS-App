//
//  CommentViewModel.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/23/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import IGListKit
class CommentViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return "\(id) comment" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? CommentViewModel else { return false }
        return id == obj.id && body == obj.body
    }
    
    let body: String
    let id: Int
    let level: Int
    let writerName: String
    let writerUsername: String
    let writerInitials: String
    let parentId: Int?
    let dateString: String
    let avatarUrlString: String
    let activeUserUsername: String
    
    init(body: String, id: Int, level: Int, writerUsername: String, writerName: String, writerInitials: String, parentId: Int?, dateString: String, avatarUrlString: String, activeUserUsername: String) {
        self.body = body
        self.id = id
        self.level = level
        self.writerUsername = writerUsername
        self.writerName = writerName
        self.parentId = parentId
        self.dateString = dateString
        self.avatarUrlString = avatarUrlString
        self.activeUserUsername = activeUserUsername
        self.writerInitials = writerInitials
    }
    
}
