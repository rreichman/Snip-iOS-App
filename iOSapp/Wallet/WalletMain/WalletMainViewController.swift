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
import RealmSwift

protocol WalletViewDelegate: class {
    func onShowAddress(type: CoinType)
    func onSendButton(type: CoinType, address: String)
    
}

class WalletMainViewController : UIViewController {
    
    @IBOutlet var headerContainer: UIView!
    @IBOutlet var balance_text: UILabel!
    @IBOutlet var usdText: UILabel!
    @IBOutlet var tableViewOutlet: UITableView!
    var notificationToken: NotificationToken? = nil
    var balanceNotificationToken: NotificationToken? = nil
    var exchangeNotificationToken: NotificationToken? = nil
    
    var token: Bool!
    var coinType: CoinType!
    var delegate: WalletViewDelegate!
    
    var userWallet: UserWallet = UserWallet()
    var exchangeData: ExchangeData?
    var transactions: Results<Transaction>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //headerContainer.sizeToFit()
        //tabelViewOutlet.tableHeaderView = headerContainer
        tableViewOutlet.allowsSelection = false
        if (coinType == nil) {
            //Backup to prevent crash, should never be nil
            coinType = CoinType.eth
        }
        token = (coinType == CoinType.snip)
        setBalance()
        
        var frame = self.view.bounds
        frame.origin.y = -frame.size.height
        let blueView = UIView(frame: frame)
        blueView.backgroundColor = UIColor(red:0, green:0.7, blue:0.8, alpha:1)
        self.tableViewOutlet.addSubview(blueView)
        
    
    }
    
    func setBalance() {
        if let view = balance_text {
            view.text = (coinType == .eth ? userWallet.readableEthBalance + " ETH" : userWallet.readableSnipBalance + " SNIP" )
        }
        
        if let view = usdText {
            if let data = exchangeData {
                let exchange = (coinType == .eth ? data.ethUsd : data.snipUsd)
                let balance = (coinType == .eth ? userWallet.convertedEthBalance : userWallet.convertedSnipBalance)
                let value = balance * Decimal(exchange)
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                view.text = "(\(formatter.string(from: value as NSDecimalNumber)!))"
            }
        }
    }
    func setTransactionData(wallet: UserWallet, exchangeData: ExchangeData) {
        self.userWallet = wallet
        self.exchangeData = exchangeData
        setBalance()
        if coinType == .eth {
            self.transactions = userWallet.transactions.filter("coin_type_string = 'eth'").filter("shouldIgnore == false").sorted(byKeyPath: "date", ascending: false )
        } else {
            self.transactions = userWallet.transactions.filter("coin_type_string = 'snip'").sorted(byKeyPath: "date", ascending: false )
        }
        
        // Observe Results Notifications
        notificationToken = transactions!.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableViewOutlet else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .none)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        
        // Observe balance change notifications
        balanceNotificationToken = userWallet.observe { [weak self] change in
            switch change {
            case .change(let properties):
                for property in properties {
                    guard let view = self else { return }
                    if property.name == "eth_balance_string" && view.coinType == .eth {
                        view.setBalance()
                    }
                    
                    if property.name == "snip_balance_string" && view.coinType == .snip {
                        view.setBalance()
                    }
                }
            case .error(let error):
                print("An error occurred: \(error)")
            case .deleted:
                print("The object was deleted.")
            }
        }
        
        exchangeNotificationToken = exchangeData.observe { [weak self] change in
            switch change {
            case .change(let properties):
                for property in properties {
                    guard let view = self else { return }
                    view.setBalance()
                }
            case .error(let error):
                print("An error occurred: \(error)")
            case .deleted:
                print("The object was deleted.")
            }
        }
        //One time requests
        
    }
    func setDelegate(del: WalletViewDelegate) {
        self.delegate = del
    }
    func setCoinType(type: CoinType) {
        coinType = type
    }
    @IBAction func onSendPressed(_ sender: UIButton) {
        delegate.onSendButton(type: coinType, address: "")
    }
    @IBAction func onSharePressed() {
        delegate.onShowAddress(type: coinType)
    }
    @IBAction func onCellSendButton(_ sender: UIButton) {
        let btn = sender as! SendAddressButton
        delegate.onSendButton(type: btn.coinType, address: btn.address)
    }
    
    deinit {
        notificationToken?.invalidate()
        if let b = balanceNotificationToken {
            b.invalidate()
        }
        if let b = exchangeNotificationToken {
            b.invalidate()
        }
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
        guard let t = self.transactions else { return 0 }
        return t.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionCell
        guard let t = self.transactions else { return cell }
        let transaction = t[indexPath.row]
        
        if transaction.coinType == .eth {
            cell.sendButton.setTitle("Send ETH", for: .normal)
            cell.sendButton.setTitle("Send ETH", for: .selected)
            cell.sendButton.setTitle("Send ETH", for: .focused)
            cell.sendButton.setTitle("Send ETH", for: .highlighted)
            cell.sendButton.coinType = .eth
            cell.amountLabel.text = EtherNumberFormatter.short.string(from: transaction.amount) + " ETH"
        } else {
            cell.sendButton.setTitle("Send SNIP", for: .normal)
            cell.sendButton.coinType = .snip
            cell.amountLabel.text = EtherNumberFormatter.short.string(from: transaction.amount) + " SNIP"
        }
        
        if (self.userWallet.hasWallet) {
            let addr = self.userWallet.address
            if transaction.sent(local: addr) {
                cell.amountLabel.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
            } else {
                cell.amountLabel.textColor = UIColor(red:0.24, green:0.71, blue:0.36, alpha:1)
            }
        } else {
            cell.amountLabel.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        }
        
        
        if !transaction.inNetwork || transaction.confirmations < 1 {
            cell.statusLabel.text = "Pending"
        } else if transaction.confirmations == 1 {
            cell.statusLabel.text = "1 Confirmation"
        } else if transaction.confirmations <= 12 {
            cell.statusLabel.text = "\(transaction.confirmations) Confirmations"
        } else {
            cell.statusLabel.text = "Confirmed"
        }
        
        if transaction.sent(local: userWallet.address) {
            cell.addressLabel.text = transaction.to_address
            cell.sendButton.address = transaction.to_address
        } else {
            cell.addressLabel.text = transaction.from_address
            cell.sendButton.address = transaction.from_address
        }
        cell.sendButton.addTarget(self, action: #selector(self.onCellSendButton(_:)),  for: .touchUpInside)
        cell.dateLabel.text = DateFmt.instance.fmt(date: transaction.date)
        cell.setConstraints()
        return cell
    }
    
    
}
class SendAddressButton: UIButton {
    var address: String
    var coinType: CoinType
    
    init(_ address: String, _ type: CoinType) {
        self.address = address
        self.coinType = type
        super.init(frame: .zero)
    }
    
    init() {
        address = ""
        coinType = .eth
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        address = ""
        coinType = .eth
        super.init(coder: aDecoder)
    }
}
