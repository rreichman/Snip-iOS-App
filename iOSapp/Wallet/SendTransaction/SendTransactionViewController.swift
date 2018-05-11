//
//  TransactionViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/18/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import BigInt

protocol SendTransactionViewDelegate: class {
    func onSend(address: String, amount: String)
    func onCancel()
    func onChangeGasSetting()
}

class SendTransactionViewController : UIViewController, UITextFieldDelegate {
    @IBOutlet var addressInput: UITextField!
    @IBOutlet var gasSettingLabel: UILabel!
    @IBOutlet var inUSDLabel: UILabel!
    @IBOutlet var maxSendLabel: UILabel!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet var changeGasSetting: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    @IBOutlet var sendButton: UIButton!
    var prefillAddress: String!
    var coinType: CoinType = .eth
    var gasSetting: GasSetting = .low
    var userWallet: UserWallet!
    var exchange: ExchangeData!
    
    var balanceUpdateNotificationToken: NotificationToken? = nil
    
    var delegate: SendTransactionViewDelegate!
    
    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        amountText.delegate = self
        addDoneButtonOnKeyboard()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SendTransactionViewController.tapFunction))
        changeGasSetting.isUserInteractionEnabled = true
        changeGasSetting.addGestureRecognizer(tap)
        
        if self.prefillAddress != nil {
            setPrefilAddress(to: self.prefillAddress)
        }
        if self.userWallet != nil {
            setMaxBalance(to: (coinType == .eth ? userWallet.ethBalance : userWallet.snipBalance))
        }
        setGasSetting(to: self.gasSetting)
        setCoinType(to: self.coinType)
    }
    
    func setInteraction(canInteract: Bool) {
        guard let _ = self.addressInput else { return }
        addressInput.isUserInteractionEnabled = canInteract
        amountText.isUserInteractionEnabled = canInteract
        sendButton.isUserInteractionEnabled = canInteract
        changeGasSetting.isUserInteractionEnabled = canInteract
        sendButton.backgroundColor = (canInteract ? UIColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1.0) : UIColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1.0))
        
    }
    
    func setModels(coinType: CoinType, gas: GasData, wallet: UserWallet, exchange: ExchangeData) {
        setCoinType(to: coinType)
        setGasSetting(to: gas.userSelection)
        self.userWallet = wallet
        setMaxBalance(to: (self.coinType == .eth ? wallet.ethBalance : wallet.snipBalance) )
        self.exchange = exchange
        
        balanceUpdateNotificationToken = wallet.observe { [weak self] change in
            switch change {
            case .change(let properties):
                for property in properties {
                    guard let view = self else { return }
                    if property.name == "eth_balance_string" && view.coinType == .eth {
                        view.setMaxBalance(to: wallet.ethBalance)
                    }
                    
                    if property.name == "snip_balance_string" && view.coinType == .snip {
                        view.setMaxBalance(to: wallet.snipBalance)
                    }
                }
            case .error(let error):
                print("An error occurred: \(error)")
            case .deleted:
                print("The object was deleted.")
            }
        }
    }
    
    func setPrefilAddress(to address: String) {
        self.prefillAddress = address
        guard let v = addressInput else { return }
        if WalletUtils.validEthAddress(address: address) {
            v.text = address
        }
    }
    
    private func setCoinType(to type: CoinType) {
        self.coinType = type
        self.navigationItem.title = (type == .eth ? "SEND ETH" : "SEND SNIP")
        if let l = self.typeLabel {
            l.text = (type == .eth ? "ETH" : "SNIP")
        }
    }
    
    func setGasSetting(to setting: GasSetting) {
        self.gasSetting = setting
        if let v = gasSettingLabel {
            v.text = GasData.labelForSetting(for: setting)
        }
    }
    
    private func setMaxBalance(to balance: BigInt) {
        let suffix = (coinType == .eth ? "ETH" : "SNIP")
        let balance = (coinType == .eth ? EtherNumberFormatter.short.string(from: balance) : EtherNumberFormatter.init().string(from: balance))
        if let v = maxSendLabel {
            v.text = "Max \(balance) \(suffix)"
        }
    }
    
    func setDelegate(del: SendTransactionViewDelegate) {
        self.delegate = del
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        delegate.onChangeGasSetting()
    }

    
    func setupNavBar() {
        self.navigationItem.title = "SEND SNIP"
        let backImage = UIImage(named: "iconClose")
        let fakeBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageView = UIImageView(image: backImage!)
        imageView.frame = CGRect(x: (44/2) - 7, y: (44/2) - 7, width: 14, height: 14)
        fakeBackButton.addSubview(imageView)
        fakeBackButton.addTarget(self, action: #selector(SendTransactionViewController.dismissModal(sender:)),  for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: fakeBackButton)
        //self.navigationController!.navigationBar.barStyle = .black
    }
    
    @IBAction func dismissModal(sender: UIButton) {
        self.delegate.onCancel()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            let rect:CGRect = info ["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.sendButtonBottomConstraint.constant = rect.height - 20
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let info = notification.userInfo {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.sendButtonBottomConstraint.constant = 10
            })
        }
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(SendTransactionViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.amountText.inputAccessoryView = doneToolbar
    }
    @IBAction func onSendPressed() {
        if let _ = addressInput {
            delegate.onSend(address: addressInput.text!, amount: amountText.text!)
        }
    }
    
    @objc func doneButtonAction() {
        self.amountText.resignFirstResponder()
    }
    
    @IBAction func swipeDown(_ sender: Any) {
        delegate.onCancel()
    }
    
    deinit {
        if let b = balanceUpdateNotificationToken {
            b.invalidate()
        }
    }
}
