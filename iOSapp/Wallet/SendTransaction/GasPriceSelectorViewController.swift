//
//  GasPriceSelectorViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/30/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

protocol GasPriceSelectorDelegate: class {
    func onSelectionMade(setting: GasSetting)
    func onCancelGasSelection()
}

class GasPriceSelectorViewController: UIViewController {
    
    @IBOutlet var lowView: UIView!
    @IBOutlet var mediumView: UIView!
    @IBOutlet var highView: UIView!
    
    @IBOutlet var lowPriceLabel: UILabel!
    @IBOutlet var lowTimeLabel: UILabel!
    @IBOutlet var mediumPriceLabel: UILabel!
    @IBOutlet var mediumTimeLabel: UILabel!
    @IBOutlet var highPriceLabel: UILabel!
    @IBOutlet var highTimeLabel: UILabel!
    
    var gasData: GasData!
    var gasPriceUpdateNotificationToken: NotificationToken?
    
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
        if gasData != nil {
            setDataLabels(data: gasData)
        }
    }
    
    func setModel(gas: GasData) {
        self.gasData = gas
        setDataLabels(data: gas)
        gasPriceUpdateNotificationToken = gasData.observe({ [weak self] (change) in
            switch change {
            case .change(let properites):
                if let v = self {
                    v.setDataLabels(data: gas)
                }
            case .error(let error):
                print(error)
            case .deleted:
                print("gas data was deleted, this will never happen")
            }
        })
    }
    
    func setDataLabels(data: GasData) {
        //If one view is loaded, they all will be ...
        guard let _ = lowPriceLabel else { return }
        lowPriceLabel.text = data.humanReadablePrice(for: .low)
        lowTimeLabel.text = "Average time \(data.humanReadableTime(for: .low))"
        mediumPriceLabel.text = data.humanReadablePrice(for: .medium)
        mediumTimeLabel.text = "Average time \(data.humanReadableTime(for: .medium))"
        highPriceLabel.text = data.humanReadablePrice(for: .high)
        highTimeLabel.text = "Average time \(data.humanReadableTime(for: .high))"
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
