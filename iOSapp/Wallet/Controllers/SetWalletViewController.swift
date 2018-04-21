//
//  SetWalletViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class SetWalletViewController : UIViewController {
    
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
        fakeBackButton.addTarget(self, action: #selector(TransactionViewController.dismissModal(sender:)),  for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: fakeBackButton)
    }
    
    @IBAction func dismissModal(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func walletCreated(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func walletImported(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
