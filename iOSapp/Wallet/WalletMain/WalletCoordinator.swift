//
//  WalletCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import BigInt
import RxSwift
import RealmSwift

class WalletCoordinator: Coordinator {
    var disposeBag: DisposeBag = DisposeBag()
    var compositeDisposable = CompositeDisposable()
    var childCoordinators: [Coordinator] = []
    var snipVC: WalletMainViewController!
    var ethVC: WalletMainViewController!
    var containerVC: WalletMainContainerViewController!
    var userWallet: UserWallet!
    
    init() {
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        self.containerVC = storyboard.instantiateViewController(withIdentifier: "WalletMainContainerViewController") as! WalletMainContainerViewController
        let ethVC = storyboard.instantiateViewController(withIdentifier: "WalletMainViewController") as! WalletMainViewController
        ethVC.setCoinType(type: .eth)
        
        let snipVC = storyboard.instantiateViewController(withIdentifier: "WalletMainViewController") as!
        WalletMainViewController
        snipVC.setCoinType(type: .snip)
        ethVC.setDelegate(del: self)
        snipVC.setDelegate(del: self)
        containerVC.snipVC = snipVC
        containerVC.ethVC = ethVC
        containerVC.setDelegate(del: self)
    }
    
    func start() {
        
        if SnipKeystore.instance.hasWallet {
            start_with_wallet()
        }
        
    }
    
    func start_with_wallet() {
        var address = SnipKeystore.instance.address!.description
        address = address.lowercased()
        let realm = RealmManager.instance.getRealm()
        guard let userWallet = realm.object(ofType: UserWallet.self, forPrimaryKey: address) else {
            print("\(address) does not have a coresponeding UserWallet realm object, todo: maybe add saftey logic here and create one")
            return
        }
        self.userWallet = userWallet
        
        containerVC.ethVC.setTransactionData(wallet: userWallet, exchangeData: RealmManager.instance.getExchangeData())
        containerVC.snipVC.setTransactionData(wallet: userWallet, exchangeData: RealmManager.instance.getExchangeData())
        
        start_polling(wallet: userWallet, realm: realm)
    }
    
    
    func start_polling(wallet: UserWallet, realm: Realm) {
        compositeDisposable.dispose()
        self.compositeDisposable = CompositeDisposable()
        compositeDisposable.disposed(by: disposeBag)
        
        if !SnipKeystore.instance.hasWallet || wallet.isInvalidated {
            print("got into start_polling with invalid wallet somehow")
            return
        }
        
        let address = wallet.address
        let exchangeData = RealmManager.instance.getExchangeData()
        
        let d = visiblePollingObservable()
            .flatMap { int -> Observable<[Transaction]> in
                return EtherscanRequest.instance.getTransactions(for: address).asObservable().catchErrorJustReturn([])
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self](tx_list) in
                let realm = RealmManager.instance.getRealm()
                try! realm.write {
                    for tx in tx_list {
                        realm.add(tx, update: true)
                        if wallet.transactions.index(of: tx) == nil {
                            wallet.transactions.append(tx)
                        }
                    }
                }
                if let v = self { v.clean_transactions() }
            }, onError: { err in
                print("\(err)")
            })
        compositeDisposable.insert(d)
        
        let d1 = visiblePollingObservable()
            .flatMap { int -> Observable<[Transaction]> in
                return EtherscanRequest.instance.getInternalTransactions(for: address).asObservable().catchErrorJustReturn([])
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (tx_list) in
                let realm = RealmManager.instance.getRealm()
                try! realm.write {
                    for tx in tx_list {
                        realm.add(tx, update: true)
                        if wallet.transactions.index(of: tx) == nil {
                            wallet.transactions.append(tx)
                        }
                    }
                }
            }, onError: { err in
                print("\(err)")
            })
        
        compositeDisposable.insert(d1)
        
        let d2 = visiblePollingObservable()
            .flatMap { int -> Single<BigInt> in
                return InfuraRequests.instance.getEthBalance(wallet: address)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (balance) in
                try! realm.write {
                    wallet.eth_balance_string = String(balance, radix: 16)
                }
            }, onError: { (err) in
                print(err)
            })
        compositeDisposable.insert(d2)
        
        let d3 = visiblePollingObservable()
            .flatMap { int -> Single<BigInt> in
                return InfuraRequests.instance.getTokenBalance(contract: NetworkSettings.getNetwork().contract_address, wallet: address)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (balance) in
                try! realm.write {
                    wallet.snip_balance_string = String(balance, radix: 16)
                }
            }, onError: { (err) in
                print(err)
            })
        compositeDisposable.insert(d3)
        
        //One time requests
        let d4 = TickerRequests.instance.getEthUsdExchange()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (rate) in
                    try! realm.write {
                        exchangeData.ethUsd = rate
                    }
            }) { (err) in
                print(err)
            }
        compositeDisposable.insert(d4)
        
        let d5 = TickerRequests.instance.getSnipEthExchange()
           
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (rate) in
                    try! realm.write {
                        exchangeData.snipEth = rate
                    }
            }) { (err) in
                print(err)
        }
        compositeDisposable.insert(d4)
    }
    
    func clean_transactions() {
        //Remove old pending transactions
        let results = RealmManager.instance.realm.objects(Transaction.self).filter("inNetwork == false")
        try! RealmManager.instance.realm.write {
            results.forEach { tx in
                // 30 Minutes
                if tx.date.timeIntervalSinceNow < -30 * 60 {
                    tx.realm?.delete(tx)
                }
            }
        }
    }
    
    func onWalletChanged() {
        let realm = RealmManager.instance.getRealm()
        guard var newAddress = SnipKeystore.instance.address?.description else {
            print("onWalletChanged called without an address set in the keystore")
            return
        }
        deleteUserWallet()
        newAddress = newAddress.lowercased()
        let newWallet = UserWallet()
        newWallet.address = newAddress
        try! realm.write {
            realm.add(newWallet, update: true)
        }
        containerVC.ethVC.setTransactionData(wallet: newWallet, exchangeData: RealmManager.instance.getExchangeData())
        containerVC.snipVC.setTransactionData(wallet: newWallet, exchangeData: RealmManager.instance.getExchangeData())
        self.userWallet = newWallet
        //Reset observables
        start_polling(wallet: newWallet, realm: realm)
    }
    
    func showAddressModal(_ type: CoinType) {
        let vc = (type == .eth) ? containerVC.ethVC : containerVC.snipVC
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        let modalVc = storyboard.instantiateViewController(withIdentifier: "ShareAddressViewController") as! ShareAddressViewController
        modalVc.modalPresentationStyle = .custom
        modalVc.transitioningDelegate = modalVc.presenterDelegate
        if let wallet = self.userWallet {
            let adr = wallet.address
            modalVc.setPublicAddress(address: adr)
        }
        
        vc?.present(modalVc, animated: true, completion: nil)
    }
    
    func showSetWallet(animated: Bool = true) {
        let setWalletCoordinator = SetWalletCoordinator(presentingViewController: containerVC)
        setWalletCoordinator.delegate = self
        childCoordinators.append(setWalletCoordinator)
        setWalletCoordinator.start(animated: animated)
    }
    
    func showSendTransactionView(type: CoinType, address: String) {
        let sendTransactionCoordinator = SendTransactionCoordinator(type: type, prefill: address, wallet: self.userWallet)
        childCoordinators.append(sendTransactionCoordinator)
        sendTransactionCoordinator.start(presentingController: (type == .eth) ? containerVC.ethVC : containerVC.snipVC)
    }
    
    func visiblePollingObservable() -> Observable<Int> {
        return Observable<Int>.interval(10, scheduler: MainScheduler.instance)
            .filter({ [containerVC] int -> Bool in
                if let v = containerVC?.ethVC {
                    if v.viewIfLoaded?.window != nil {
                        return true
                    }
                }
                if let v = containerVC?.snipVC {
                    if v.viewIfLoaded?.window != nil {
                        return true
                    }
                }
                return false
            })
            .observeOn(SingleBackgroundThread.scheduler)
    }
    
    func deleteUserWallet() {
        compositeDisposable.dispose()
        let realm = RealmManager.instance.getRealm()
        let userwallets = realm.objects(UserWallet.self)
        try! realm.write {
            for wallet in userwallets {
                realm.delete(wallet)
            }
        }
    }
    
    func removeWallet() {
        deleteUserWallet()
        SnipKeystore.instance.deleteWallet()
        showSetWallet()
    }
    
    func changePin() {
        let navController = UINavigationController()
        containerVC.present(navController, animated: true, completion: nil)
        let pinCoord = PinCoordinator(navController: navController, mode: .change, delegate: self)
        pinCoord.start()
    }
    
    func onContainerTabSelected() {
        if !SnipKeystore.instance.hasWallet {
            showSetWallet(animated: true)
        }
    }
    
    deinit {
        ethVC = nil
        snipVC = nil
        containerVC = nil
    }
}

extension WalletCoordinator: PinCoordinatorDelegate {
    func entryCancled() {
        //pass
    }
    
    func entrySuccessful() {
        //pass
    }
}

extension WalletCoordinator: SetWalletCoordinatorDelegate {
    func finished(walletChanged: Bool) {
        if walletChanged {
            onWalletChanged()
        } else {
            if !SnipKeystore.instance.hasWallet {
                containerVC.backToHomeTab()
            }
        }
    }
}

extension WalletCoordinator: WalletViewDelegate {
    func onShowAddress(type: CoinType) {
        showAddressModal(type)
    }
    
    func onSendButton(type: CoinType, address: String) {
        showSendTransactionView(type: type, address: address)
    }

}

extension WalletCoordinator: WalletMainContainerDelegate {
    func onViewDisplay() {
        onContainerTabSelected()
    }
    
    func onRemoveWalletRequested() {
        removeWallet()
    }
    
    func onChangePinRequested() {
        changePin()
    }
    
}
