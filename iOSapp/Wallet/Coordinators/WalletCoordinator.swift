//
//  WalletCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class WalletCoordinator: Coordinator {
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
    }
    
    func showAddressModal(_ type: CoinType) {
        let vc = (type == .eth) ? containerVC.ethVC : containerVC.snipVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let modalVc = storyboard.instantiateViewController(withIdentifier: "ShareAddressViewController") as! ShareAddressViewController
        modalVc.modalPresentationStyle = .custom
        modalVc.transitioningDelegate = modalVc.presenterDelegate
        
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
