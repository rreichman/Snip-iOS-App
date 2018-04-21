//
//  WalletViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit


class WalletViewController : UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var balance_text: UILabel!
    
    var token: Bool!
    var coinType: CoinType!
    enum CoinType {
        case snip
        case eth
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (coinType == nil) {
            //Backup to prevent crash, should never be nil
            coinType = CoinType.eth
        }
        token = (coinType == CoinType.snip)
        if (token) {
            balance_text.text = "0 SNIP"
        }
    }
    
    
    
    func setCoinType(type: CoinType) {
        coinType = type
    }
    
    @IBAction func saveName2(segue: UIStoryboardSegue) {
        
        
    }
    
}
