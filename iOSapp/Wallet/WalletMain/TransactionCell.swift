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
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
}
