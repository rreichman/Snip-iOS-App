//
//  ConfirmationViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/14/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import BigInt
protocol ConfirmationViewDelegate {
    func onConfirmed()
    func onBack()
}
class ConfirmationViewController : UIViewController {
    let presenterDelegate = ConfirmationPresentationDelegate()
    @IBOutlet var backButton: UIButton!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var sendingLabel: UILabel!
    @IBOutlet var sendingUSDLabel: UILabel!
    @IBOutlet var gasLabel: UILabel!
    @IBOutlet var gasUSDLabel: UILabel!
    @IBOutlet var containerView: UIView!
    
    var coinType: CoinType = .eth
    var amount: BigInt!
    var gas: BigInt!
    
    var exchangeData: ExchangeData!
    
    var delegate: ConfirmationViewDelegate!
    
    override func viewDidLoad() {
        if let _ = self.exchangeData {
            display_data()
        }
    }
    
    func setData(amount: BigInt, gas: BigInt, exchangeData: ExchangeData, type: CoinType) {
        self.amount = amount
        self.gas = gas
        self.exchangeData = exchangeData
        self.coinType = type
        display_data()
    }
    
    func display_data() {
        guard let _ = self.sendingLabel else { return }
        let exchange = (coinType == .eth ? exchangeData.ethUsd : exchangeData.snipUsd)
        let nf = EtherNumberFormatter.short
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let suffix = (coinType == .eth ? "ETH" : "SNIP")
        sendingLabel.text = "\(nf.string(from: amount)) \(suffix)"
        
        let usd = nf.decimal(from: amount, decimals: 18)! * Decimal(exchange)
        let str = formatter.string(from: usd as NSDecimalNumber)!
        sendingUSDLabel.text = "(\(str))"
        
        gasLabel.text = "\(EtherNumberFormatter().string(from: self.gas)) ETH"
        
        let gasUSD = nf.decimal(from: gas, decimals: 18)!
        if gasUSD < 0.01 {
            gasUSDLabel.text = "(<$0.01)"
        } else {
            let gasStr = formatter.string(from: gasUSD as NSDecimalNumber)!
            gasUSDLabel.text = "(\(gasStr))"
        }
        
        
    }
    @IBAction func onConfirmButton() {
        delegate.onConfirmed()
    }
    
    @IBAction func onBackButton() {
        delegate.onBack()
    }
}
