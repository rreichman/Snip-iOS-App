//
//  WriterHeaderSectionController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class WriterHeaderSectionController: ListSectionController {
    var model: WriterHeaderViewModel?
    override init() {
        super.init()
        
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { fatalError() }
        // Top Padding: 10, Avatar Height: 75, Padding: 20, Label Height: 23, bottom padding: 20
        return CGSize(width: width, height: 148)
        
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "WriterHeaderCollectionCell", bundle: nil, for: self, at: index) as? WriterHeaderCollectionCell else { fatalError() }
        cell.model = self.model
        return cell
    }
    
    override func didUpdate(to object: Any) {
        guard let obj = object as? WriterHeaderViewModel else { fatalError() }
        self.model = obj
    }
}
