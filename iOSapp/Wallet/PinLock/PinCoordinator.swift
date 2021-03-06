//
//  PinCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/27/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol PinCoordinatorDelegate: class {
    func entryCancled()
    func entrySuccessful()
}

class PinCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var inSecondEntry: Bool = false
    var firstEntry: String = ""
    var viewController: PinViewController!
    
    var navController: UINavigationController?
    var delegate: PinCoordinatorDelegate!
    var mode: PinPadAction
    var lock: PinLock
    init(navController: UINavigationController?, mode: PinPadAction, delegate: PinCoordinatorDelegate) {
        self.navController = navController
        self.mode = mode
        self.delegate = delegate
        self.lock = PinLock.instance
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "PinViewController") as? PinViewController
        viewController!.setDelegate(delegate: self)
        if let nc = self.navController {
            nc.pushViewController(viewController!, animated: true)
        }
        self.firstEntry = ""
        setLableForMode()
        
    }
    func getLabelForMode() -> String {
		switch mode {
        case .change:
			return "Enter current pincode"
        case .create:
        	if !self.inSecondEntry {
            	return "Create a 6-digit pincode to quicky access your wallet"
            } else {
                return "Repeat pincode"
            }
        case .verify:
            return "Enter pincode"
        }
	}
    func setLableForMode() {
		let l = getLabelForMode()
		viewController.setLabel(label: l)
    }
    func matchPin(_ pin: String) -> Bool {
        return lock.pinCode == pin
    }
    
    func onPinEntry(with pin: String) {
        unowned let unownedSelf = self
        viewController.setInteraction(canInteract: false)
        let deadlineTime = DispatchTime.now() + .milliseconds(100)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            unownedSelf.onPinEntryDelayed(with: pin)
            if let v = unownedSelf.viewController {
                v.setInteraction(canInteract: true)
            }
        })
        
    }
    
    func onPinEntryDelayed(with pin: String) {
        switch mode {
        case .change:
            if matchPin(pin) {
                self.mode = .create
                self.firstEntry = ""
                self.inSecondEntry = false
                viewController.clearDisplay()
                setLableForMode()
            } else {
                viewController.onWrongInput()
            }
        case .verify:
            if matchPin(pin) {
                onSuccess()
            } else {
                viewController.onWrongInput()
            }
        case .create:
            if !inSecondEntry {
                self.firstEntry = pin
                self.inSecondEntry = true
                viewController.clearDisplay()
                setLableForMode()
            } else {
                if pin == firstEntry {
                    lock.pinCode = pin
                    onSuccess()
                } else {
                    viewController.onWrongInput()
                    self.firstEntry = ""
                    self.inSecondEntry = false
                    setLableForMode()
                }
            }
        }
    }
    
    func onSuccess() {
        
        if let nc = self.navController {
            if nc.viewControllers.count == 1 {
                nc.dismiss(animated: true, completion: nil)
            } else {
                nc.popViewController(animated: true)
            }
        }
        self.delegate.entrySuccessful()
        self.delegate = nil
        self.viewController = nil
        self.navController = nil
    }
    
    func onBackPressed() {
        if let nc = navController {
            if nc.viewControllers.count == 1 {
                nc.dismiss(animated: true, completion: nil)
            } else {
                nc.popViewController(animated: true)
            }
        } else {
            viewController.dismiss(animated: true, completion: nil)
        }
        self.delegate.entryCancled()
        self.delegate = nil
        self.viewController = nil
        self.navController = nil
    }
    
    
}

extension PinCoordinator: PinViewDelegate {
    func pinEntered(pin: String) {
        onPinEntry(with: pin)
    }
    
    func backPressed() {
        onBackPressed()
    }
    
    
}
