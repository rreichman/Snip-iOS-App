//
//  SnipHeaderView.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/17/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

class SnipFooterView: UITableViewHeaderFooterView {
    static let reuseIdent = "SnipFooterReuseIdentifier"
    
    let catLabel = UILabel.init()
    let moreLabel = UILabel.init()
    
    var category: Category!
    var delegate: CategorySelectionDelegate!
    
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        catLabel.font = UIFont.lato(size: 15)
        catLabel.textColor = UIColor(red:0, green:0.63, blue:0.71, alpha:1)
        catLabel.translatesAutoresizingMaskIntoConstraints = false
        
        moreLabel.font = UIFont.lato(size: 15)
        moreLabel.textColor = UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1.0)
        moreLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(catLabel)
        self.contentView.addSubview(moreLabel)
        
        catLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        let bot = catLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bot.isActive = false
        catLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        catLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        moreLabel.topAnchor.constraint(equalTo: catLabel.topAnchor).isActive = true
        let bot2 = moreLabel.bottomAnchor.constraint(equalTo: catLabel.bottomAnchor)
        bot2.isActive = false
        moreLabel.trailingAnchor.constraint(equalTo: catLabel.leadingAnchor, constant: -3).isActive = true
        //moreLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor).isActive = true
        moreLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        catLabel.text = "Test"
        moreLabel.text = "More"
        addTap()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func addTap() {
        catLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(titleTap))
        catLabel.addGestureRecognizer(tap)
    }
    @objc func titleTap() {
        delegate.onCategorySelected(category: self.category)
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
