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
    var firstEntry: String = ""
    var viewController: PinViewController!
    
    var navController: UINavigationController!
    var delegate: PinCoordinatorDelegate!
    var mode: PinPadAction
    init(navController: UINavigationController, mode: PinPadAction, delegate: PinCoordinatorDelegate) {
        self.navController = navController
        self.mode = mode
        self.delegate = delegate
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "PinViewController") as? PinViewController
        viewController?.setDelegate(delegate: self)
        navController.pushViewController(viewController!, animated: true)
    }
    
    func onSuccess(pin: String) {
        navController.popViewController(animated: true)
        self.delegate.entrySuccessful()
        self.delegate = nil
        self.viewController = nil
        self.navController = nil
    }
    
    func onBackPressed() {
        navController.popViewController(animated: true)
        self.delegate.entryCancled()
        self.delegate = nil
        self.viewController = nil
        self.navController = nil
        
    }
    
    
}

extension PinCoordinator: PinViewDelegate {
    func pinEntered(pin: String) {
        onSuccess(pin: pin)
    }
    
    func backPressed() {
        onBackPressed()
    }
    
    
}
