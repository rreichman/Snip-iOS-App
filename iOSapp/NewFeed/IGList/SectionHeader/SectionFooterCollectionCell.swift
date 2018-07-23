//
//  SectionFooterView.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/21/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

class SectionFooterCollectionCell: UICollectionViewCell {
    weak var delegate: PostInteractionDelegate?
    
    @IBOutlet var categoryLabel: UILabel!
    
    var categoryName: String = "" {
        didSet {
            if let _ = self.categoryLabel {
                bindView()
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.numberOfLines = 1
        
        
        
        categoryLabel.isUserInteractionEnabled = true
        categoryLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCategory)))
        
        bindView()
        
    }
    
    func bindView() {
        
        categoryLabel.text = "\(categoryName)"
        
    }
    
    @objc func showCategory() {
        if let d = self.delegate {
            d.showCategoryPosts(categoryName: self.categoryName)
        }
    }

}
