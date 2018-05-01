//
//  SnipWalletController.swift
//  iOSapp
//
//  Created by Ran Reichman on 4/6/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import TrustKeystore

protocol SnipWalletViewDelegate: class {
    func tabSelected(coin: CoinType)
    func onSettingsPressed()
}

class SnipWalletController : UIViewController {
    
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var ethTab : UIButton!
    @IBOutlet var snipTab : UIButton!
    var buttons: [UIButton]!
    
    
    @IBOutlet var contentView: UIView!
    var selectedIndex: Int = 0
    var delegate: SnipWalletViewDelegate!
    
    @IBAction func onSettingsPress() {
        delegate.onSettingsPressed()
    }
    
    func setDelegate(del: SnipWalletViewDelegate) {
        self.delegate = del
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let coord = WalletCoordinator(container: self)
        coord.start()
        buttons = [ethTab, snipTab]
       
        
        
        //backHeaderView.titleTopConstraint.constant = 32
        let bundlePath = Bundle.main.path(forResource: "TrustWeb3Provider", ofType: "bundle")
        let bundle = Bundle(path: bundlePath!)!
        let jsPath = bundle.path(forResource: "trust-min", ofType: "js")
        let data = NSData(contentsOfFile: jsPath!)
        print(data?.length)
        let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keysDirectory = URL(fileURLWithPath: datadir + "/keystore")
        let keyStore = try! KeyStore(keyDirectory: keysDirectory)
        let string = "miracle lady exhibit potato kangaroo segment swamp tooth neglect ritual vibrant daring"
        do {
            let accounts = try keyStore.accounts
            for a in accounts {
                print("adr \(a.address) url \(a.url.absoluteString) ")
            }
        } catch {
            print("Unexpected error: \(error).")
        }
        
        buildSettingsButton()
    }
    
    func setTab(type: CoinType, subView: UIView, controller: UIViewController) {
        if (type == .snip) {
            ethTab.isSelected = false
            snipTab.isSelected = true
        } else {
            ethTab.isSelected = true
            snipTab.isSelected = false
        }
        addChildViewController(controller)
        subView.frame = contentView.bounds
        contentView.addSubview(subView)
    }
    
    
    @IBAction func didPress(_ sender: UIButton) {
        selectedIndex = sender.tag
        if (selectedIndex == 1) {
            //snip
            delegate.tabSelected(coin: .snip)
        } else {
            //eth
            delegate.tabSelected(coin: .eth)
        }
    }
    
    func buildSettingsButton() {
        let image = UIImage(named: "settings")
        let imageView = UIImageView(image: image!)
        let w = settingsButton.frame.width
        imageView.frame = CGRect(x: (w/2) - 10, y: (w/2)-10, width: 20, height: 20)
        settingsButton.addSubview(imageView)
    }
}
