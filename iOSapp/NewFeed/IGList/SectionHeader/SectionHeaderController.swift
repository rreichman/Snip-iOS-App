//
//  HeaderFooterController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class SectionHeaderController: ListSectionController {
   
    
    var model: Any?
    weak var delegate: PostInteractionDelegate?
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { fatalError() }
        
        switch self.model {
        case is SectionHeaderViewModel:
            return CGSize(width: width, height: 35)
        case is SectionFooterViewModel:
            return CGSize(width: width, height: 28)
        default:
            fatalError()
        }
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let model = self.model else { fatalError() }
        var cell: UICollectionViewCell
        
        switch self.model {
        case is SectionHeaderViewModel:
            guard let cellOptional = collectionContext?.dequeueReusableCell(withNibName: "SectionHeaderCollectionCell", bundle: nil, for: self, at: index) as? SectionHeaderCollectionCell else {
                fatalError()
            }
            cellOptional.delegate = self.delegate
            cellOptional.categoryName = (model as! SectionHeaderViewModel).categoryName
            cell = cellOptional
        case is SectionFooterViewModel:
            guard let cellOptional = collectionContext?.dequeueReusableCell(withNibName: "SectionFooterCollectionCell", bundle: nil, for: self, at: index) as? SectionFooterCollectionCell else {
                fatalError()
            }
            cellOptional.delegate = self.delegate
            cellOptional.categoryName = (model as! SectionFooterViewModel).categoryName
            cell = cellOptional
        default:
            fatalError()
        }
        return cell
    }
    override func didUpdate(to object: Any) {
        self.model = object
    }
    
}
