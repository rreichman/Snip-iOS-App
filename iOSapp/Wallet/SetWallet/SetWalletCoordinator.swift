//
//  SetWalletCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/23/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import TrustCore
import RxSwift

protocol SetWalletCoordinatorDelegate: class {
    func finished(walletChanged: Bool)
}

class SetWalletCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let disposeBag: DisposeBag = DisposeBag()
    var errored: Bool = false
    
    var navigationController: UINavigationController!
    weak var delegate: SetWalletCoordinatorDelegate?
    var creationType: SetWalletType!
    weak var presentingVC: UIViewController?
    
    var containerVC: SetWalletViewController?
    var newWalletVC: NewWalletViewController?
    var importWalletVC: ImportWalletViewController?
    
    init (presentingViewController: UIViewController) {
        self.presentingVC = presentingViewController
    }
    
    func start(animated: Bool) {
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        self.navigationController = storyboard.instantiateViewController(withIdentifier: "SetWalletNavController") as! UINavigationController
        let controller = storyboard.instantiateViewController(withIdentifier: "SetWalletViewController") as! SetWalletViewController
        self.containerVC = controller
        controller.setDelegate(delegate: self)
        navigationController.viewControllers = [controller] as [UIViewController]
        
        self.presentingVC!.present(navigationController, animated: animated, completion: nil)
    }
    
    //Step 1 - Get mode
    func setType(for creation: SetWalletType) {
        creationType = creation
    }
    
    //Step 2 - Set a pin
    func showPin() {
        let pinCoordinator = PinCoordinator(navController: navigationController, mode: .create, delegate: self)
        self.childCoordinators.append(pinCoordinator)
        pinCoordinator.start()
        
    }
    
    func showResult() {
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        if creationType == SetWalletType.import_wallet {
            let controller = storyboard.instantiateViewController(withIdentifier: "ImportWalletViewController")
            importWalletVC = controller as! ImportWalletViewController
            navigationController.pushViewController(controller, animated: true)
            importWalletVC?.setDelegate(delegate: self)
        } else {
            let controller = storyboard.instantiateViewController(withIdentifier: "NewWalletViewController")
            newWalletVC = controller as! NewWalletViewController
            navigationController.pushViewController(controller, animated: true)
            SnipKeystore.instance.createWallet()
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { p in
                            self.newWalletVC?.setPhrase(phrase: p)
						},
				   		onError: { error in
				   			self.newWalletVC?.setPhrase(phrase: "Error creating wallet, try again")
                            print("Error: ", error)
                            self.errored = true
                		})
                .disposed(by: disposeBag)
            newWalletVC?.setDelegate(delegate: self)
        }
    }
    
    //Step 3a - Generate new wallet and phrase
    func donePressed() {
        
        navigationController.dismiss(animated: true, completion: nil)
        if errored {
            delegate!.finished(walletChanged: false)
        } else {
            delegate!.finished(walletChanged: true)
            SnipLoggerRequests.instance.logNewWallet(imported: self.creationType == SetWalletType.import_wallet)
        }
    }
    
    //Step 3b - Get import phrase
    func checkPhrase(phrase: String) {
        importWalletVC?.setInteraction(canInteract: false)
        SnipKeystore.instance.debugDeleteAll()
        SnipKeystore.instance
            .importWallet(phrase: phrase)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (address) in
                self.navigationController.dismiss(animated: true, completion: nil)
                self.delegate?.finished(walletChanged: true)
            }, onError: { (err) in
                self.importWalletVC!.showError(msg: "Unable to import wallet with that phrase")
                self.importWalletVC!.setInteraction(canInteract: true)
                
            })
            .disposed(by: disposeBag)
    }
    
    func import_canceled() {
        if importWalletVC != nil {
            navigationController.popToRootViewController(animated: true)
            importWalletVC = nil
        }
        
    }
    func pinFailed() {
        
    }
}

extension SetWalletCoordinator: SetWalletViewDelegate {
    func onBackPressed() {
        guard let nav = self.navigationController else { return }
        if let d = self.delegate {
            d.finished(walletChanged: false)
        }
        nav.dismiss(animated: true, completion: nil)
    }
    
    func selectionMade(mode: SetWalletType) {
        self.creationType = mode
        showPin()
    }
    
    
}
extension SetWalletCoordinator: PinCoordinatorDelegate {
    func entryCancled() {
        // pass
        childCoordinators.removeAll()
    }
    
    func entrySuccessful() {
        childCoordinators.removeAll()
        showResult()
    }
}

extension SetWalletCoordinator: NewWalletViewDelegate {
    func onDonePressed() {
        donePressed()
    }
}

extension SetWalletCoordinator: ImportWalletViewDelegate {
    func phraseEntered(phrase: String) {
        checkPhrase(phrase: phrase)
    }
    
    func backPressed() {
        import_canceled()
    }
    
    
}
