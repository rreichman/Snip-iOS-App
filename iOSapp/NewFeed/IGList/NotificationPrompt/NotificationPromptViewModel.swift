//
//  NotificationPromptViewModel.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import IGListKit

// Placeholder View Model to satisfy ListDiffable

class NotificationPromptViewModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return "NotificationPromptViewModel" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
    
    
}
