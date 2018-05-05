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
    @IBOutlet var tabelViewOutlet: UITableView!
    
    var token: Bool!
    var coinType: CoinType!
    var delegate: WalletViewDelegate!
    
    var transactions: [Transaction] = []
    
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
    func setTransactionData(data: [Transaction]) {
        self.transactions = data
        
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

extension WalletMainViewController: UITableViewDelegate {
    
}

extension WalletMainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionCell
        let transaction = self.transactions[indexPath.row]
        if transaction.coinType == .eth {
            cell.sendButton.titleLabel!.text = "Send ETH"
        } else {
            cell.sendButton.titleLabel!.text = "Send SNIP"
        }
        //cell.statusLabel.text = transaction.status
        cell.amountLabel.text = EtherNumberFormatter.short.string(from: transaction.amount)
        cell.dateLabel.text = DateFmt.instance.fmt(date: transaction.date)
        return cell
    }
    
    
}
