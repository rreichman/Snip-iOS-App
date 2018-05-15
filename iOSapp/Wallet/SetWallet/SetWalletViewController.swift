//
//  SetWalletViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol SetWalletViewDelegate: class {
    func selectionMade(mode: SetWalletType)
    func onBackPressed()
}
class SetWalletViewController : UIViewController {
    var delegate: SetWalletViewDelegate?
    
    func setDelegate(delegate: SetWalletViewDelegate) {
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        setupNavBar()
    }
    func setupNavBar() {
        self.navigationItem.title = "SNIP WALLET"
        let backImage = UIImage(named: "iconClose")
        let fakeBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageView = UIImageView(image: backImage!)
        imageView.frame = CGRect(x: (44/2) - 7, y: (44/2) - 7, width: 14, height: 14)
        fakeBackButton.addSubview(imageView)
        fakeBackButton.addTarget(self, action: #selector(SendTransactionViewController.dismissModal(sender:)),  for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: fakeBackButton)
    }
    
    func showError(msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func dismissModal(sender: UIButton) {
        if let d = delegate {
            d.onBackPressed()
        }
    }
    
    @IBAction func newWallet() {
        self.delegate?.selectionMade(mode: .new_wallet)
    }
    
    @IBAction func importWallet() {
        self.delegate?.selectionMade(mode: .import_wallet)
    }
    
}
