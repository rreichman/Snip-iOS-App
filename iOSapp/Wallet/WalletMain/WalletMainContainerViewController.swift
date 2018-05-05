//
//  SnipWalletController.swift
//  iOSapp
//
//  Created by Ran Reichman on 4/6/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import TrustKeystore
import XLPagerTabStrip
import LatoFont

protocol WalletMainContainerDelegate: class {
    func onSettingsPressed()
}

class WalletMainContainerViewController : ButtonBarPagerTabStripViewController {
    @IBOutlet var settingsButton: UIButton!
    
    public var ethVC: WalletMainViewController!
    public var snipVC: WalletMainViewController!
    
    @IBOutlet var contentView: UIView!
    var _delegate: WalletMainContainerDelegate!
    
    @IBAction func onSettingsPress() {
        _delegate.onSettingsPressed()
    }
    
    func setDelegate(del: WalletMainContainerDelegate) {
        self._delegate = del
    }
    
    override func viewDidLoad() {
        buildBar()
        super.viewDidLoad()
        let coord = WalletCoordinator(container: self)
        coord.start()
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
        buildSettingsButton()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        ethVC = storyboard.instantiateViewController(withIdentifier: "WalletMainViewController") as? WalletMainViewController
        ethVC.setCoinType(type: .eth)
        
        snipVC = storyboard.instantiateViewController(withIdentifier: "WalletMainViewController") as?
        WalletMainViewController
        snipVC.setCoinType(type: .snip)
        return [snipVC, ethVC]
    }
    
    func buildSettingsButton() {
        let image = UIImage(named: "settings")
        let imageView = UIImageView(image: image!)
        let w = settingsButton.frame.width
        imageView.frame = CGRect(x: (w/2) - 10, y: (w/2)-10, width: 20, height: 20)
        settingsButton.addSubview(imageView)
    }
    /*
    func move_indicator(pos: Int) {
        let tabView: UIView = (pos == 0 ? snipTab : ethTab)
       
        indicatorConstraint.isActive = false
        indicatorConstraint = self.indicatorView.centerXAnchor.constraint(equalTo: tabView.centerXAnchor, constant: 0.0)
        indicatorConstraint.isActive = true
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
 */
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func buildBar() {
        let snipBlue = UIColor(red:0, green:0.7, blue:0.8, alpha:1)
        
        settings.style.buttonBarBackgroundColor = snipBlue
        settings.style.buttonBarItemBackgroundColor = snipBlue
        settings.style.selectedBarBackgroundColor = .white
        settings.style.buttonBarItemFont = UIFont.latoBold(size: 16)
        settings.style.buttonBarItemTitleColor = .white
        settings.style.buttonBarItemsShouldFillAvailableWidth = false
        settings.style.buttonBarItemLeftRightMargin = 20
        
        settings.style.selectedBarBackgroundColor = .white
        settings.style.selectedBarHeight = 2.0
        

        
    }
    
}
