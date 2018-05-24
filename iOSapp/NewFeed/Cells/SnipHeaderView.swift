//
//  SnipHeaderView.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/17/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

protocol CategorySelectionDelegate: class {
    func onCategorySelected(category: Category)
}

class SnipHeaderView: UITableViewHeaderFooterView {
    static let reuseIdent = "SnipHeaderViewReuse"
    
    let catLabel = UILabel.init()
    var category: Category!
    var delegate: CategorySelectionDelegate!
    
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        catLabel.font = UIFont.latoBold(size: 20)
        catLabel.textColor = UIColor(red:0, green:0.63, blue:0.71, alpha:1)
        catLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(catLabel)
        
        catLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        catLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
        let bot = catLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        //bot.priority = .defaultHigh
        bot.isActive = false
        //catLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        catLabel.heightAnchor.constraint(equalToConstant: 54).isActive = true
        catLabel.text = "Category"
        addTap()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCatLabel(title: String) {
        catLabel.text = "\(title)  ›"
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
