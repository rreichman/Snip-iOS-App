//
//  SnipWalletController.swift
//  iOSapp
//
//  Created by Ran Reichman on 4/6/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import TrustKeystore

class SnipWalletController : UIViewController {
    
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var ethTab : UIButton!
    @IBOutlet var snipTab : UIButton!
    var buttons: [UIButton]!
    
    var ethTabViewController: WalletViewController!
    var snipTabViewController: WalletViewController!
    
    @IBOutlet var contentView: UIView!
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons = [ethTab, snipTab]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        ethTabViewController = storyboard.instantiateViewController(withIdentifier: "WalletController") as! WalletViewController
        ethTabViewController.setCoinType(type: WalletViewController.CoinType.eth)
        snipTabViewController = storyboard.instantiateViewController(withIdentifier: "WalletController") as! WalletViewController
        snipTabViewController.setCoinType(type: WalletViewController.CoinType.snip)
        
        
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
        
        ethTab.isSelected = true
        didPress(ethTab)
        buildSettingsButton()
    }
    
    @IBAction func didPress(_ sender: UIButton) {
        selectedIndex = sender.tag
        var prevVc, selectedVc: UIViewController!
        if (selectedIndex == 1) {
            prevVc = ethTabViewController
            selectedVc = snipTabViewController
            ethTab.isSelected = false
        } else {
            prevVc = snipTabViewController
            selectedVc = ethTabViewController
            snipTab.isSelected = false
        }
        
        prevVc.willMove(toParentViewController: nil)
        prevVc.view.removeFromSuperview()
        prevVc.removeFromParentViewController()
        
        sender.isSelected = true
        addChildViewController(selectedVc)
        selectedVc.view.frame = contentView.bounds
        contentView.addSubview(selectedVc.view)
        selectedVc.didMove(toParentViewController: self)
    }
    
    func buildSettingsButton() {
        let image = UIImage(named: "settings")
        let imageView = UIImageView(image: image!)
        let w = settingsButton.frame.width
        imageView.frame = CGRect(x: (w/2) - 10, y: (w/2)-10, width: 20, height: 20)
        settingsButton.addSubview(imageView)
    }
}
