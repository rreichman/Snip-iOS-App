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
    var snipVC: WalletViewController!
    var ethVC: WalletViewController!
    var containerVC: SnipWalletController
    
    let test_address = "0x7a8f2734d08927b7a569e4887b81f714ba1a82aa"
    
    init(container: SnipWalletController) {
        self.containerVC = container
        container.setDelegate(del: self)
        
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        snipVC = storyboard.instantiateViewController(withIdentifier: "WalletController") as! WalletViewController
        snipVC.setCoinType(type: .snip)
        snipVC.setDelegate(del: self)
        ethVC = storyboard.instantiateViewController(withIdentifier: "WalletController") as! WalletViewController
        ethVC.setCoinType(type: .eth)
        ethVC.setDelegate(del: self)
        showTab(coin: .eth)
    }
    
    func showTab(coin: CoinType) {
        var prevVc, selectedVc: UIViewController!
        if (coin == .snip) {
            prevVc = ethVC
            selectedVc = snipVC
        } else {
            prevVc = snipVC
            selectedVc = ethVC
        }
        
        prevVc.willMove(toParentViewController: nil)
        prevVc.view.removeFromSuperview()
        prevVc.removeFromParentViewController()
        
        containerVC.setTab(type: coin, subView: selectedVc.view, controller: selectedVc)
        selectedVc.didMove(toParentViewController: containerVC)
    }
    
    func showAddressModal(_ type: CoinType) {
        let vc = (type == .eth) ? ethVC : snipVC
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
        sendTransactionCoordinator.start(presentingController: (type == .eth) ? ethVC : snipVC)
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

extension WalletCoordinator: SnipWalletViewDelegate {
    func tabSelected(coin: CoinType) {
        showTab(coin: coin)
    }
    func onSettingsPressed() {
        showSetWallet()
    }
    
    
}
