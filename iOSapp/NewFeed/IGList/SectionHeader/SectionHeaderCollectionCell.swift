//
//  HeaderFooterCollectionCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

class SectionHeaderCollectionCell: UICollectionViewCell {

    var categoryName: String = "" {
        didSet {
            if let v = self.categoryLabel {
                bindView()
            }
        }
    }
    
    weak var delegate: PostInteractionDelegate?
    
    @IBOutlet var categoryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.numberOfLines = 1
        
        categoryLabel.font = UIFont.montserratBlack(size: 20)
        categoryLabel.textColor = UIColor(red: 0, green: 0.7, blue: 0.8, alpha: 1.0)
        categoryLabel.isUserInteractionEnabled = true
        categoryLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCategory)))
        bindView()
    }
    
    func bindView() {
        categoryLabel.text = "\(categoryName.uppercased())  ›"
        
    }
    
    @objc func showCategory() {
        if let d = self.delegate {
            d.showCategoryPosts(categoryName: self.categoryName)
        }
    }

}
