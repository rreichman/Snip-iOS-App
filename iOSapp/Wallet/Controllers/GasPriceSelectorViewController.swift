//
//  GasPriceSelectorViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/30/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol GasPriceSelectorDelegate: class {
    func onSelectionMade(setting: GasSetting)
    func onCancelGasSelection()
}

class GasPriceSelectorViewController: UIViewController {
    
    @IBOutlet var lowView: UIView!
    @IBOutlet var mediumView: UIView!
    @IBOutlet var highView: UIView!
    
    var delegate: GasPriceSelectorDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        whiteBackArrow()
        
        let tapLow = UITapGestureRecognizer(target: self, action: #selector(GasPriceSelectorViewController.tapLow))
        lowView.isUserInteractionEnabled = true
        lowView.addGestureRecognizer(tapLow)
        let tapMedium = UITapGestureRecognizer(target: self, action: #selector(GasPriceSelectorViewController.tapMedium))
        mediumView.isUserInteractionEnabled = true
        mediumView.addGestureRecognizer(tapMedium)
        let tapHigh = UITapGestureRecognizer(target: self, action: #selector(GasPriceSelectorViewController.tapHigh))
        highView.isUserInteractionEnabled = true
        highView.addGestureRecognizer(tapHigh)
    }
    
    @objc func tapLow(sender:UITapGestureRecognizer) {
        delegate.onSelectionMade(setting: .low)
    }
    
    @objc func tapMedium(sender:UITapGestureRecognizer) {
        delegate.onSelectionMade(setting: .medium)
    }
    
    @objc func tapHigh(sender:UITapGestureRecognizer) {
        delegate.onSelectionMade(setting: .high)
    }
    
    func setDelegate(del: GasPriceSelectorDelegate) {
        self.delegate = del
    }
    private func whiteBackArrow() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 18, height: 18)
        menuBtn.setImage(UIImage(named:"whiteBackArrow"), for: .normal)
        menuBtn.addTarget(self, action: #selector(backButtonTapped), for: UIControlEvents.touchUpInside)
        menuBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 18)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 18)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    @objc func backButtonTapped() {
        delegate?.onCancelGasSelection()
    }
}
