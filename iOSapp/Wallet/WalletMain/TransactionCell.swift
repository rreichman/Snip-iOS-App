//
//  TransactionCell.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class TransactionCell: UITableViewCell {
    @IBOutlet var cell: UIView!
    
    @IBOutlet var sendButton: SendAddressButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setConstraints() {
        let width = frame.width
        addressLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 0.50 * width).isActive = true
        addressLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -8).isActive = true
        addressLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8).isActive = true
        addressLabel.adjustsFontSizeToFitWidth = false
        addressLabel.lineBreakMode = .byTruncatingMiddle
    }
}
