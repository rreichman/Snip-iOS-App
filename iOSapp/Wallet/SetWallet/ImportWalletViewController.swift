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
    
    @IBOutlet var importButton: UIButton!
    @IBOutlet var wordCountLabel: UILabel!
    @IBOutlet var phraseInput: UITextField!
    @IBOutlet var importButtonConstraint: NSLayoutConstraint!
    var delegate: ImportWalletViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        whiteBackArrow()
        //importButton.setTitleColor(UIColor.red, for: .disabled)
        
        dynamicButtonPosition()
        phraseInput.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        updateWordCount()
        
    }
    
    func setDelegate(delegate: ImportWalletViewDelegate) {
        self.delegate = delegate
    }
    
    func showError(err: String) {
        
    }
    
    func setInteraction(canInteract: Bool) {
        importButton.isUserInteractionEnabled = canInteract
        if !canInteract {
            importButton.backgroundColor = UIColor(red: 0.8, green: 0.94, blue: 0.96, alpha: 1.0)
        } else {
            importButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1.0)
        }
        phraseInput.isUserInteractionEnabled = canInteract
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
    
    func showError(msg: String) {
        print(msg)
        
        
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
    
    func updateWordCount() {
        if let s = phraseInput.text {
            let word_count = s.split(separator: " ").count
            if let l = self.wordCountLabel {
                l.text = "\(word_count) \((word_count == 1 ? "word" : "words"))"
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
    }
}
