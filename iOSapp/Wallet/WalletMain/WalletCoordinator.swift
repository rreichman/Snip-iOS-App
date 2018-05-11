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
    
    let test_address = "0x7a8f2734d08927b7a569e4887b81f714ba1a82aa"
    
    init(container: WalletMainContainerViewController) {
        self.containerVC = container
        container.setDelegate(del: self)
        
    }
    
    func start() {
        containerVC.ethVC.setDelegate(del: self)
        containerVC.snipVC.setDelegate(del: self)
        
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
        let address = wallet.address
        let exchangeData = RealmManager.instance.getExchangeData()
        
        let d = visiblePollingObservable()
            .flatMap { int -> Observable<[Transaction]> in
                return EtherscanRequest.instance.getTransactions(for: address).asObservable().catchErrorJustReturn([])
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
                return InfuraRequests.instance.getTokenBalance(contract: NetworkSettings.rinkeby.contract_address, wallet: address)
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
    
    func onWalletChanged() {
        let realm = RealmManager.instance.getRealm()
        let userwallet = realm.objects(UserWallet.self)
        guard var newAddress = SnipKeystore.instance.address?.description else {
            print("onWalletChanged called without an address set in the keystore")
            return
        }
        
        newAddress = newAddress.lowercased()
        let newWallet = UserWallet()
        newWallet.address = newAddress
        try! realm.write {
            if userwallet.count == 0 {
                print("No old wallet in realm, no deletion needed")
            } else if userwallet.count == 1 {
                print("Deleting old wallet from realm")
                realm.delete(userwallet[0])
            } else {
                print("!!!!!!!!!!!!!!!!!! Why is there more than one wallet in the realm")
                realm.delete(userwallet)
            }
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let modalVc = storyboard.instantiateViewController(withIdentifier: "ShareAddressViewController") as! ShareAddressViewController
        modalVc.modalPresentationStyle = .custom
        modalVc.transitioningDelegate = modalVc.presenterDelegate
        if let wallet = self.userWallet {
            let adr = wallet.address
            modalVc.setPublicAddress(address: adr)
        }
        
        vc?.present(modalVc, animated: true, completion: nil)
    }
    
    func showSetWallet() {
        let setWalletCoordinator = SetWalletCoordinator(presentingViewController: containerVC)
        setWalletCoordinator.delegate = self
        childCoordinators.append(setWalletCoordinator)
        setWalletCoordinator.start()
    }
    
    func showSendTransactionView(type: CoinType, address: String) {
        let sendTransactionCoordinator = SendTransactionCoordinator(type: type, prefill: address, wallet: self.userWallet)
        childCoordinators.append(sendTransactionCoordinator)
        sendTransactionCoordinator.start(presentingController: (type == .eth) ? containerVC.ethVC : containerVC.snipVC)
    }
    
    func visiblePollingObservable() -> Observable<Int> {
        return Observable<Int>.interval(3, scheduler: MainScheduler.instance)
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
    
    func onContainerTabSelected() {
        if !SnipKeystore.instance.hasWallet {
            showSetWallet()
        }
    }
    
    deinit {
        ethVC = nil
        snipVC = nil
        containerVC = nil
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
    
    func onSettingsPressed() {
        showSetWallet()
    }
    
    
}
