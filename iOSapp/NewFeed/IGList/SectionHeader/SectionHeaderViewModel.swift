//
//  CateogryHeaderFooterModel.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import IGListKit

class SectionHeaderViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return "\(categoryName) header" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? SectionHeaderViewModel else { return false }
        return categoryName == obj.categoryName
    }
    
    
    let categoryName: String
    
    init(categoryName: String) {
        self.categoryName = categoryName
    }
}
