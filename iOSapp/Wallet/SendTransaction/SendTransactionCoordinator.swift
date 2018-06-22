//
//  SendTransactionCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/27/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import RxSwift
import BigInt
import TrustCore

class SendTransactionCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var disposeBag = DisposeBag()
    var navController: UINavigationController!
    var sendTransactionVC: SendTransactionViewController!
    var gasSettingVC: GasPriceSelectorViewController?
    var transactionSummaryVC: TransactionSummaryController?
    var confirmationVC: ConfirmationViewController?
    var pinCoordinator: PinCoordinator?
    var type: CoinType
    var prefillAddress: String
    var userWallet: UserWallet!
    var transactionPendingPin: (String, String)?
    init(type: CoinType, prefill address: String, wallet: UserWallet) {
        self.type = type
        self.prefillAddress = address
        self.userWallet = wallet
    }
    
    func start(presentingController: UIViewController) {
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        self.navController = storyboard.instantiateViewController(withIdentifier: "SendTransactionNavigationController") as! UINavigationController
        self.sendTransactionVC = storyboard.instantiateViewController(withIdentifier: "SendTransactionViewController") as! SendTransactionViewController
        sendTransactionVC.setDelegate(del: self)
        sendTransactionVC.setPrefilAddress(to: prefillAddress)
        
        let realm = RealmManager.instance.getRealm()
        let gasData = RealmManager.instance.getGasData()
        let exchange = RealmManager.instance.getExchangeData()
        sendTransactionVC.setModels(coinType: type, gas: gasData, wallet: userWallet, exchange: exchange)
        sendTransactionVC.setPrefilAddress(to: self.prefillAddress)
        navController.viewControllers = [sendTransactionVC]
        presentingController.show(navController, sender: nil)
        
        fetch(with: realm)
    }
    
    func fetch(with realm: Realm) {
        GasRequests.instance.getGasData()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (data) in
                let global = RealmManager.instance.getGasData()
                data.user_selection_int = global.user_selection_int
                try! realm.write {
                    realm.add(data, update: true)
                }
            }) { (err) in
                print(err)
            }
            .disposed(by: disposeBag)
        if type == .eth {
            InfuraRequests.instance.getEthBalance(wallet: userWallet.address)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [userWallet] (bal) in
                    try! realm.write {
                        userWallet!.eth_balance_string = String(bal, radix: 16)
                    }
                }) { (err) in
                    print(err)
                }
                .disposed(by: disposeBag)
        } else {
            InfuraRequests.instance.getTokenBalance(contract: NetworkSettings.getNetwork().contract_address, wallet: userWallet.address)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [userWallet] (bal) in
                    try! realm.write {
                        userWallet!.snip_balance_string = String(bal, radix: 16)
                    }
                }) { (err) in
                    print(err)
                }
                .disposed(by: disposeBag)
        }
        
    }
    
    func sendTransaction(address: String, amount_string: String) {
        guard let vc = sendTransactionVC else { return }
        vc.setInteraction(canInteract: false)
        
        let gasData = RealmManager.instance.getGasData()
        guard let wallet = userWallet else { return }
        guard let amountInt = BigInt(amount_string) else {
            //bad amount error
            return
        }
        let amountField = (type == .eth ? amountInt : BigInt(0))
        let data = (type == .eth ? Data() : ERC20Encoder.encodeTransfer(to: Address(string: address)!, tokens: amountInt.magnitude))
        let to = (type == .eth ? address : NetworkSettings.getNetwork().contract_address)
        let gasLimit = (type == .eth ? GasLimit.eth : GasLimit.snip)
        
        var pendingTransaction: Transaction!
        InfuraRequests.instance.getTransactionCount(address: wallet.address)
            .flatMap { [type] (nonce) -> Single<String> in
                let n = wallet.compareRemoteNonce(remote: nonce)
                let signTransaction = try SnipKeystore.instance.makeTransaction(to: to, gasData: gasData, gasLimit: gasLimit, amount: amountField, nonce: n, data: data)
                let (rawTransaction, hash) = try SnipKeystore.instance.signTransaction(signTransaction)
                pendingTransaction = wallet.addPendingTransaction(to: to, amount: amountInt, coinType: type, hash: hash)
                return InfuraRequests.instance.sendRawTransaction(raw: rawTransaction)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self, transactionPendingPin](hash) in
                print("hash: \(hash)")
                
                guard let view = self else {
                    return
                }
                if let v = view.sendTransactionVC {
                    v.setInteraction(canInteract: true)
                }
                view.showTransactionSummary(to: transactionPendingPin!.0, for: BigInt(transactionPendingPin!.1)!)
            }) { [weak self, pendingTransaction](err) in
                print(err)
                if let pt = pendingTransaction {
                    try! pt.realm!.write {
                        pt.failed = true
                    }
                }
                
                guard let v = self else { return }
                if let vc = v.sendTransactionVC {
                    vc.showError(msg: "There was a problem sending the transaction")
                    vc.setInteraction(canInteract: true)
                }
            }.disposed(by: disposeBag)
        
    }
    
    func openGasSettingModal() {
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        gasSettingVC = storyboard.instantiateViewController(withIdentifier: "GasPriceSelectorViewController") as? GasPriceSelectorViewController
        gasSettingVC!.setDelegate(del: self)
        gasSettingVC!.setModel(gas: RealmManager.instance.getGasData())
        navController.pushViewController(gasSettingVC!, animated: true)
    }
    
    func showConfirmationSheet(type: CoinType, amount: BigInt, gas: BigInt, exchangeData: ExchangeData) {
        let main = UIStoryboard(name: "Wallet", bundle: nil)
        confirmationVC = (main.instantiateViewController(withIdentifier: "Confirmation") as! ConfirmationViewController)
        confirmationVC!.modalPresentationStyle = .custom
        confirmationVC!.transitioningDelegate = confirmationVC!.presenterDelegate
        sendTransactionVC.present(confirmationVC!, animated: true)
        confirmationVC!.setData(amount: amount, gas: gas, exchangeData: exchangeData, type: type)
        confirmationVC!.delegate = self
    }
    
    func showPinForVerification() {
        pinCoordinator = PinCoordinator(navController: navController, mode: .verify, delegate: self)
        pinCoordinator?.start()
        
    }
    
    func onPinVerified() {
        pinCoordinator = nil
        guard let pending = self.transactionPendingPin else {
            //silently fail I guess, this should never happen
            return
        }
        
        // Call send transaction and pass this as callback
        sendTransaction(address: pending.0, amount_string: pending.1)
    }
    
    func showTransactionSummary(to address: String, for amount: BigInt) {
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        transactionSummaryVC = storyboard.instantiateViewController(withIdentifier: "TransactionSummaryViewController") as? TransactionSummaryController
        transactionSummaryVC!.setDelegate(del: self)
        let amountString = (self.type == .eth ? "\(EtherNumberFormatter.short.string(from: amount)) ETH" : "\(EtherNumberFormatter.init().string(from: amount)) SNIP")
        transactionSummaryVC!.setAddressAndAmount(to: address, with: amountString)
        navController.pushViewController(transactionSummaryVC!, animated: true)
    }
    
    func dismissSendVc() {
        if let n = navController {
            n.dismiss(animated: true, completion: nil)
        }
    }
    
    func dismissGasModel() {
        if gasSettingVC != nil {
            navController.popViewController(animated: true)
            gasSettingVC = nil
        }
    }
    
    func saveSelection(for setting: GasSetting) {
        let realm = RealmManager.instance.getRealm()
        let data = RealmManager.instance.getGasData()
        try! realm.write {
            data.setUserSelection(to: setting)
        }
    }
    
    func updateVCWithGasSetting(for setting: GasSetting) {
        if sendTransactionVC != nil {
            sendTransactionVC.setGasSetting(to: setting)
        }
    }
    
    func dismissTransactionSummary() {
        navController.dismiss(animated: true) {
            self.sendTransactionVC = nil
            self.gasSettingVC = nil
            self.pinCoordinator = nil
            self.transactionSummaryVC = nil
            self.navController = nil
        }
    }
    
    func transactionRequested(to address: String, with amount: String) {
        guard let vc = self.sendTransactionVC else { return }
        if !WalletUtils.validEthAddress(address: address) {
            sendTransactionVC.showError(msg: "Invalid address")
            return
        }
        guard let amount_int = Double(amount) else {
            sendTransactionVC.showError(msg: "Invalid amount")
            return
        }
        
        guard let amount_in_wei = EtherNumberFormatter.init().number(from: amount) else {
            sendTransactionVC.showError(msg: "Invalid amount")
            return
        }
        if amount_in_wei <= 0{
            sendTransactionVC.showError(msg: "Amount must be greater than 0")
            return
        }
        if amount_in_wei > (self.type == .eth ? userWallet.ethBalance : userWallet.snipBalance) {
            sendTransactionVC.showError(msg: "Amount is greater than wallet balance")
            return
        }
        self.transactionPendingPin = (address, String(amount_in_wei))
        
        let gas_data = RealmManager.instance.getGasData()
        let exchange_data = RealmManager.instance.getExchangeData()
        showConfirmationSheet(type: type, amount: amount_in_wei, gas: gas_data.priceInWei(for: gas_data.userSelection), exchangeData: exchange_data)
    }
}

extension SendTransactionCoordinator: ConfirmationViewDelegate {
    func onConfirmed() {
        if let c = self.confirmationVC {
            c.dismiss(animated: true, completion: nil)
        }
        sendTransactionVC.view.endEditing(true)
        showPinForVerification()
    }
    
    func onBack() {
        if let c = self.confirmationVC {
            c.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

extension SendTransactionCoordinator: SendTransactionViewDelegate {
    func onSend(address: String, amount: String) {
        transactionRequested(to: address, with: amount)
    }
    
    func onChangeGasSetting() {
        openGasSettingModal()
    }
    func onCancel() {
        dismissSendVc()
    }
}
extension SendTransactionCoordinator: GasPriceSelectorDelegate {
    func onSelectionMade(setting: GasSetting) {
        saveSelection(for: setting)
        dismissGasModel()
        updateVCWithGasSetting(for: setting)
    }
    func onCancelGasSelection() {
        dismissGasModel()
    }
    
}

extension SendTransactionCoordinator: PinCoordinatorDelegate {
    func entryCancled() {
        //pass
    }
    
    func entrySuccessful() {
        onPinVerified()
    }
}
extension SendTransactionCoordinator: TransactionSummaryViewDelegate {
    func finishedViewing() {
        dismissTransactionSummary()
    }
}
