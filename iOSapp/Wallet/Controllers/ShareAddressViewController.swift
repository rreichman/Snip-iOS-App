//
//  ShareAddressViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/27/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol ShareAddressDelegate: class {
    
}

class ShareAddressViewController: UIViewController {
    let presenterDelegate = TransitionDelegate()
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var qrCodeView: UIImageView!
    
    override func viewDidLoad() {
    }
    @IBAction func swipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onCopyButton() {
    }
    @IBAction func onOtherShare() {
    }
    @IBAction func onClose() {
        dismiss(animated: true, completion: nil)
    }
}
