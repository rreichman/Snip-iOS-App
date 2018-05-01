//
//  ImportWalletViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol ImportWalletViewDelegate: class {
    func phraseEntered(phrase: String)
    func backPressed()
}
class ImportWalletViewController : UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var phraseInput: UITextField!
    @IBOutlet var importButtonConstraint: NSLayoutConstraint!
    var delegate: ImportWalletViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        whiteBackArrow()
        dynamicButtonPosition()
    }
    
    func setDelegate(delegate: ImportWalletViewDelegate) {
        self.delegate = delegate
    }
    
    func showError(err: String) {
        
    }
    
    private func dynamicButtonPosition() {
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            let rect:CGRect = info ["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.importButtonConstraint.constant = rect.height - 20
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let info = notification.userInfo {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.importButtonConstraint.constant = 10
            })
        }
    }
    
    @IBAction func importPressed() {
        if let p = phraseInput.text {
            delegate?.phraseEntered(phrase: p)
        }
    }
    @objc func backButtonTapped() {
        delegate?.backPressed()
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
}
