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
    func verifyPin(for type:SetWalletType)
}

class SetWalletCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let disposeBag: DisposeBag = DisposeBag()
    
    var navigationController: UINavigationController!
    weak var delegate: SetWalletCoordinatorDelegate?
    var creationType: SetWalletType!
    weak var presentingVC: UIViewController?
    
    var newWalletVC: NewWalletViewController?
    var importWalletVC: ImportWalletViewController?
    
    init (presentingViewController: UIViewController) {
        self.presentingVC = presentingViewController
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.navigationController = storyboard.instantiateViewController(withIdentifier: "SetWalletNavController") as! UINavigationController
        let controller = storyboard.instantiateViewController(withIdentifier: "SetWalletViewController") as! SetWalletViewController
        controller.setDelegate(delegate: self)
        navigationController.viewControllers = [controller] as [UIViewController]
        self.presentingVC?.show(navigationController, sender: nil)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
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
							self.newWalletVC?.setInteraction(canInteract: true)
                            self.newWalletVC?.setPhrase(phrase: p)
						},
				   		onError: { error in
				   			self.newWalletVC?.setPhrase(phrase: error.localizedDescription)
                            print("Error: ", error)
                		})
                .disposed(by: disposeBag)
            newWalletVC?.setDelegate(delegate: self)
        }
    }
    
    //Step 3a - Generate new wallet and phrase
    func newWalletCreated() {
        //do some service shit
        
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    //Step 3b - Get import phrase
    func checkPhrase(phrase: String) {
        importWalletVC?.setInteraction(canInteract: false)
        SnipKeystore.instance.debugDeleteAll()
        SnipKeystore.instance
            .importWallet(phrase: phrase)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (address) in
                //next
                //assert(address.description == "0x1b4f8ac6b16524360a09a5bd182cd03fb08fa38f")
                self.navigationController.dismiss(animated: true, completion: nil)
            }, onError: { (err) in
                self.importWalletVC?.showError(err: err.localizedDescription)
                self.importWalletVC?.setInteraction(canInteract: true)
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
        newWalletCreated()
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
