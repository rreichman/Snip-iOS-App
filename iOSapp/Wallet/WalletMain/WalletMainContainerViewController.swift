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
}

class WalletMainContainerViewController : ButtonBarPagerTabStripViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet var settingsButton: UIButton!
    
    public var ethVC: WalletMainViewController!
    public var snipVC: WalletMainViewController!
    @IBOutlet var contentView: UIView!
    var _delegate: WalletMainContainerDelegate!
    weak var coordinator: WalletCoordinator?
    @IBAction func onSettingsPress() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        var popover = story.instantiateViewController(withIdentifier: "SettingPopover") as! SettingPopoverViewController
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
        if let coord = self.coordinator {
            coord.onContainerTabSelected()
        }
        
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
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
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // return UIModalPresentationStyle.FullScreen
        return UIModalPresentationStyle.none
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

extension WalletMainContainerViewController: SettingPopoverViewDelegate {
    func onRemoveRequested() {
        self._delegate.onRemoveWalletRequested()
    }
    
    func onChangeRequested() {
        self._delegate.onChangePinRequested()
    }
    
    
}
