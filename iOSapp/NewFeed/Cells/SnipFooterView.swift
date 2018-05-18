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
    
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        catLabel.font = UIFont.lato(size: 15)
        catLabel.textColor = UIColor(red:0, green:0.63, blue:0.71, alpha:1)
        catLabel.translatesAutoresizingMaskIntoConstraints = false
        
        moreLabel.font = UIFont.lato(size: 15)
        moreLabel.textColor = UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1.0)
        moreLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(catLabel)
        self.contentView.addSubview(moreLabel)
        self.contentView.backgroundColor = UIColor.white
        
        catLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        let bot = catLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bot.priority = .defaultHigh
        bot.isActive = true
        catLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        moreLabel.topAnchor.constraint(equalTo: catLabel.topAnchor).isActive = true
        let bot2 = moreLabel.bottomAnchor.constraint(equalTo: catLabel.bottomAnchor)
        bot2.priority = .defaultHigh
        bot2.isActive = true
        moreLabel.trailingAnchor.constraint(equalTo: catLabel.leadingAnchor, constant: -3).isActive = true
        moreLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor).isActive = true
        catLabel.text = "Test"
        moreLabel.text = "More"
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
