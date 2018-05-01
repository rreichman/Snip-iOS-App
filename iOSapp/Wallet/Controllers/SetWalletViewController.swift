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
        self.navigationItem.title = "SEND SNIP"
        let backImage = UIImage(named: "iconClose")
        let fakeBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageView = UIImageView(image: backImage!)
        imageView.frame = CGRect(x: (44/2) - 7, y: (44/2) - 7, width: 14, height: 14)
        fakeBackButton.addSubview(imageView)
        fakeBackButton.addTarget(self, action: #selector(SendTransactionViewController.dismissModal(sender:)),  for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: fakeBackButton)
    }
    
    
    @IBAction func dismissModal(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newWallet() {
        self.delegate?.selectionMade(mode: .new_wallet)
    }
    
    @IBAction func importWallet() {
        self.delegate?.selectionMade(mode: .import_wallet)
    }
    
}
