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
    @IBOutlet var indicatorView: UIView!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var ethTab : UIButton!
    @IBOutlet var snipTab : UIButton!
    @IBOutlet var tabContainer: UIView!
    var buttons: [UIButton]!
    
    
    @IBOutlet var contentView: UIView!
    var selectedIndex: Int = 0
    var delegate: SnipWalletViewDelegate!
    var indicatorConstraint: NSLayoutConstraint!
    
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
        
        
        //setup the first constraint, move_ind will handle the rest
        indicatorConstraint = indicatorView.centerXAnchor.constraint(equalTo: snipTab.centerXAnchor, constant: 0.0)
        indicatorConstraint.isActive = true
        /*
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
        */
        didPress(snipTab)
        buildSettingsButton()
    }
    
    func setTab(type: CoinType, subView: UIView, controller: UIViewController) {
        if (type == .snip) {
            ethTab.isSelected = false
            snipTab.isSelected = true
            move_indicator(pos: 0)
        } else {
            ethTab.isSelected = true
            snipTab.isSelected = false
            move_indicator(pos: 1)
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
    func move_indicator(pos: Int) {
        let tabView: UIView = (pos == 0 ? snipTab : ethTab)
       
        indicatorConstraint.isActive = false
        indicatorConstraint = self.indicatorView.centerXAnchor.constraint(equalTo: tabView.centerXAnchor, constant: 0.0)
        indicatorConstraint.isActive = true
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
extension UIView {
    func callRecursively(level: Int = 0, _ body: (_ subview: UIView, _ level: Int) -> Void) {
        body(self, level)
        subviews.forEach { $0.callRecursively(level: level + 1, body) }
    }
}
