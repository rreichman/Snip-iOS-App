//
//  SendTransactionCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/27/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class SendTransactionCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navController: UINavigationController!
    var sendTransactionVC: SendTransactionViewController!
    var gasSettingVC: GasPriceSelectorViewController?
    var transactionSummaryVC: TransactionSummaryController?
    var pinCoordinator: PinCoordinator?
    var type: CoinType
    
    init(type: CoinType) {
        self.type = type
    }
    
    func start(presentingController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.navController = storyboard.instantiateViewController(withIdentifier: "SendTransactionNavigationController") as! UINavigationController
        self.sendTransactionVC = storyboard.instantiateViewController(withIdentifier: "SendTransactionViewController") as! SendTransactionViewController
        sendTransactionVC.setDelegate(del: self)
        navController.viewControllers = [sendTransactionVC]
        presentingController.show(navController, sender: nil)
    }
    
    func openGasSettingModal() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        gasSettingVC = storyboard.instantiateViewController(withIdentifier: "GasPriceSelectorViewController") as? GasPriceSelectorViewController
        gasSettingVC?.setDelegate(del: self)
        navController.pushViewController(gasSettingVC!, animated: true)
    }
    
    func showPinForVerification() {
        pinCoordinator = PinCoordinator(navController: navController, mode: .verify, delegate: self)
        pinCoordinator?.start()
        
    }
    
    func onPinVerified() {
        pinCoordinator = nil
        showTransactionSummary()
    }
    
    func showTransactionSummary() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        transactionSummaryVC = storyboard.instantiateViewController(withIdentifier: "TransactionSummaryViewController") as? TransactionSummaryController
        transactionSummaryVC?.setDelegate(del: self)
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
    
    func dismissTransactionSummary() {
        navController.dismiss(animated: true) {
            self.sendTransactionVC = nil
            self.gasSettingVC = nil
            self.pinCoordinator = nil
            self.transactionSummaryVC = nil
            self.navController = nil
        }
    }
}

extension SendTransactionCoordinator: SendTransactionViewDelegate {
    func onSend(address: String, amount: String) {
        showPinForVerification()
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
        dismissGasModel()
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
