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
    func onRemoveWalletRequested()
    func onChangePinRequested()
    func onViewDisplay()
}

class WalletMainContainerViewController : ButtonBarPagerTabStripViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet var settingsButton: UIButton!
    
    public var ethVC: WalletMainViewController!
    public var snipVC: WalletMainViewController!
    @IBOutlet var contentView: UIView!
    var _delegate: WalletMainContainerDelegate!
    weak var coordinator: WalletCoordinator?
    
    @IBAction func onSettingsPress() {
        let story = UIStoryboard(name: "Wallet", bundle: nil)
        let popover = story.instantiateViewController(withIdentifier: "SettingPopover") as! SettingPopoverViewController
        popover.delegate = self
        popover.updatePopOverViewController(settingsButton, with: self)
        present(popover, animated: true, completion: nil)
        //_delegate.onSettingsPressed()
    }
    /*
    func showOnViewLoad(nav: UINavigationController) {
        if self.isViewLoaded {
            self.show(nav, sender: nil)
        } else {
            self.onLoadView = {() in
                self.show(nav, sender: nil)
            }
        }
    }*/
    func setDelegate(del: WalletMainContainerDelegate) {
        self._delegate = del
    }
    func backToHomeTab() {
        if let ct = self.tabBarController {
            ct.selectedIndex = 0
        }
    }
    override func viewDidLoad() {
        buildBar()
        super.viewDidLoad()
        buildSettingsButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let d = self._delegate {
            d.onViewDisplay()
        }
        
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        return [snipVC, ethVC]
    }
    
    func buildSettingsButton() {
        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: 44, height: 44)
        settingsButton.imageEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 0)
        settingsButton.setImage(UIImage(named:"whiteSettingsCog"), for: .normal)
        settingsButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.0).isActive = true
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
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // return UIModalPresentationStyle.FullScreen
        return UIModalPresentationStyle.none
    }
    func buildBar() {
        let snipBlue = UIColor(red:0, green:0.7, blue:0.8, alpha:1)
        settings.style.buttonBarBackgroundColor = snipBlue
        settings.style.buttonBarItemBackgroundColor = snipBlue
        settings.style.selectedBarBackgroundColor = .white
        settings.style.buttonBarItemFont = UIFont.latoBlack(size: 16.0)
        settings.style.buttonBarItemTitleColor = .white
        settings.style.buttonBarItemsShouldFillAvailableWidth = false
        settings.style.buttonBarItemLeftRightMargin = 20
        settings.style.selectedBarBackgroundColor = .white
        settings.style.selectedBarHeight = 2.0
    }
    
}

extension WalletMainContainerViewController: SettingPopoverViewDelegate {
    func onRemoveRequested() {
        self._delegate.onRemoveWalletRequested()
    }
    
    func onChangeRequested() {
        self._delegate.onChangePinRequested()
    }
    
    
}
