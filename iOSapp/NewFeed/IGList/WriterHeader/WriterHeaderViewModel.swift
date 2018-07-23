//
//  WriterHeaderViewModel.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import IGListKit

class WriterHeaderViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return (writerUsername + "header") as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? WriterHeaderViewModel else { return false }
        return writerUsername == obj.writerUsername && avatarUrl == obj.avatarUrl
    }
    
    let writerName: String
    let writerUsername: String
    let avatarUrl: String?
    let initials: String
    
    init(writerName: String, writerUsername: String, avatarUrl: String?, initials: String) {
        self.writerName = writerName
        self.writerUsername = writerUsername
        self.avatarUrl = avatarUrl
        self.initials = initials
    }
}
