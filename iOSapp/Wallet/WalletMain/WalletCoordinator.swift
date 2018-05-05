//
//  WalletCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RealmSwift

class WalletCoordinator: Coordinator {
    let disposeBag: DisposeBag = DisposeBag()
    
    var childCoordinators: [Coordinator] = []
    var snipVC: WalletMainViewController!
    var ethVC: WalletMainViewController!
    var containerVC: WalletMainContainerViewController
    
    let test_address = "0x7a8f2734d08927b7a569e4887b81f714ba1a82aa"
    
    init(container: WalletMainContainerViewController) {
        self.containerVC = container
        container.setDelegate(del: self)
        
    }
    
    func start() {
        containerVC.ethVC.setDelegate(del: self)
        containerVC.snipVC.setDelegate(del: self)
        testNetwork()
    }
    
    func testData() -> [Transaction] {
        let transaction1 = Transaction()
        transaction1.to_address = "0x1b4f8ac6b16524360a09a5bd182cd03fb08fa38f"
        transaction1.from_address = "0x7a8f2734d08927b7a569e4887b81f714ba1a82aa"
        transaction1.timestamp = 1522283117
        transaction1.date = Date(timeIntervalSinceReferenceDate: TimeInterval(transaction1.timestamp))
        transaction1.coin_type_string = "eth"
        transaction1.transaction_hash = "0x24f3261b262f3a143a9a658183cff6e41276714a7cc190196bf2ddc7f724c890"
        transaction1.amount_string = "25000000000000000"
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(transaction1, update:true)
        }
        return [transaction1]
    }
    
    func testNetwork() {
        EtherscanRequest.instance.getTransactions(for: "0x1b4f8ac6b16524360a09a5bd182cd03fb08fa38f")
            .subscribe(onSuccess: { tx_list in
                let realm = RealmManager.instance.getRealm()
                try! realm.write {
                    for tx in tx_list {
                        realm.add(tx, update: true)
                    }
                }
                self.containerVC.ethVC.setTransactionData(data: tx_list.filter { $0.coinType == CoinType.eth })
            }, onError: { err in
                print("\(err)")
            })
            .disposed(by: disposeBag)
    }
    
    func showAddressModal(_ type: CoinType) {
        let vc = (type == .eth) ? containerVC.ethVC : containerVC.snipVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let modalVc = storyboard.instantiateViewController(withIdentifier: "ShareAddressViewController") as! ShareAddressViewController
        modalVc.modalPresentationStyle = .custom
        modalVc.transitioningDelegate = modalVc.presenterDelegate
        if let a = SnipKeystore.instance.address {
            let adr = a.description
            modalVc.setPublicAddress(address: adr)
        }
        
        vc?.present(modalVc, animated: true, completion: nil)
    }
    
    func showSetWallet() {
        let setWalletCoordinator = SetWalletCoordinator(presentingViewController: containerVC)
        childCoordinators.append(setWalletCoordinator)
        setWalletCoordinator.start()
    }
    
    func showSendTransactionView(type: CoinType) {
        let sendTransactionCoordinator = SendTransactionCoordinator(type: type)
        childCoordinators.append(sendTransactionCoordinator)
        sendTransactionCoordinator.start(presentingController: (type == .eth) ? containerVC.ethVC : containerVC.snipVC)
    }
}

extension WalletCoordinator: WalletViewDelegate {
    func onShowAddress(type: CoinType) {
        showAddressModal(type)
    }
    
    func onSendButton(type: CoinType) {
        showSendTransactionView(type: type)
    }

}

extension WalletCoordinator: WalletMainContainerDelegate {
    
    func onSettingsPressed() {
        showSetWallet()
    }
    
    
}
