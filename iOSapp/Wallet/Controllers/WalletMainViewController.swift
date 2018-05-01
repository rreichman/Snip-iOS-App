//
//  WalletViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

protocol WalletViewDelegate: class {
    func onShowAddress(type: CoinType)
    func onSendButton(type: CoinType)
    
}

class WalletMainViewController : UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var balance_text: UILabel!
    
    var token: Bool!
    var coinType: CoinType!
    var delegate: WalletViewDelegate!
    
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
    func setDelegate(del: WalletViewDelegate) {
        self.delegate = del
    }
    func setCoinType(type: CoinType) {
        coinType = type
    }
    @IBAction func onSendPressed(_ sender: UIButton) {
        delegate.onSendButton(type: coinType)
    }
    @IBAction func onSharePressed() {
        delegate.onShowAddress(type: coinType)
    }
    
    
    
}

extension WalletMainViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: (coinType == .snip ? "SNIP" : "ETH" ))
    }
    
    
}
