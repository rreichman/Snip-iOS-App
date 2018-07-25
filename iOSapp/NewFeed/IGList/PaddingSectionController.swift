//
//  PaddingSectionController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/25/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import IGListKit
import UIKit

func paddingSectionController(height: CGFloat, backgroundColor: UIColor) -> ListSingleSectionController {
    let configureBlock = { (item: Any, cell: UICollectionViewCell) in
        guard let cell = cell as? PaddingCell else { return }
        cell.contentView.backgroundColor = backgroundColor
        cell.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
        guard let context = context else { return .zero }
        return CGSize(width: context.containerSize.width, height: height)
    }
    
    return ListSingleSectionController(cellClass: PaddingCell.self,
                                       configureBlock: configureBlock,
                                       sizeBlock: sizeBlock)
}

final class PaddingCell: UICollectionViewCell {
    
    
}
