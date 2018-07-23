//
//  SectionFooterViewModel.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/21/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class SectionFooterViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return "\(categoryName) footer" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? SectionFooterViewModel else { return false }
        return categoryName == obj.categoryName
    }
    
    
    let categoryName: String
    
    init(categoryName: String) {
        self.categoryName = categoryName
    }
}
