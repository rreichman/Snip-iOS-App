//
//  TransactionViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/18/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol SendTransactionViewDelegate: class {
    func onSend(address: String, amount: String)
    func onCancel()
    func onChangeGasSetting()
}

class SendTransactionViewController : UIViewController, UITextFieldDelegate {
    var delegate: SendTransactionViewDelegate!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet var changeGasSetting: UILabel!
    
    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        amountText.delegate = self
        addDoneButtonOnKeyboard()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SendTransactionViewController.tapFunction))
        changeGasSetting.isUserInteractionEnabled = true
        changeGasSetting.addGestureRecognizer(tap)
    }
    
    func setDelegate(del: SendTransactionViewDelegate) {
        self.delegate = del
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        delegate.onChangeGasSetting()
    }

    
    func setupNavBar() {
        self.navigationItem.title = "SEND SNIP"
        let backImage = UIImage(named: "iconClose")
        let fakeBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageView = UIImageView(image: backImage!)
        imageView.frame = CGRect(x: (44/2) - 7, y: (44/2) - 7, width: 14, height: 14)
        fakeBackButton.addSubview(imageView)
        fakeBackButton.addTarget(self, action: #selector(SendTransactionViewController.dismissModal(sender:)),  for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: fakeBackButton)
    }
    
    @IBAction func dismissModal(sender: UIButton) {
        self.delegate.onCancel()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            let rect:CGRect = info ["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.sendButtonBottomConstraint.constant = rect.height - 20
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let info = notification.userInfo {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.sendButtonBottomConstraint.constant = 10
            })
        }
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(SendTransactionViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.amountText.inputAccessoryView = doneToolbar
    }
    @IBAction func onSendPressed() {
        delegate.onSend(address: "", amount: "")
    }
    
    @objc func doneButtonAction() {
        self.amountText.resignFirstResponder()
    }
    
}
