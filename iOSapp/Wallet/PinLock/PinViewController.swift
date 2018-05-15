//
//  PinViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/23/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol PinViewDelegate: class {
    
    // 6 Digit pin code entered. Called twice when setting a new pincode
    func pinEntered(pin: String)
    func backPressed()
}

class PinViewController : UIViewController {
    var delegate: PinViewDelegate!
    var input: String = ""
    @IBOutlet var pinButtons : [UIButton]!
    @IBOutlet var messageView: UILabel!
    
    @IBOutlet var inputContainer: UIView!
    @IBOutlet var displayViews: [UIView]!
    var message: String?
    func setDelegate(delegate: PinViewDelegate) {
        self.delegate = delegate
    }
    override func viewDidLoad() {
        whiteBackArrow()
        displayViews.sort(by: {
            let tag1 = $0.tag
            let tag2 = $1.tag
            return tag1 < tag2
        })
		
		if let m = message {
			if let mv = messageView {
				mv.text = m
			}
		}
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0, green:0.7, blue:0.8, alpha:1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white, NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.lato(size: 16)]
    }
    
    func setInteraction(canInteract: Bool) {
        for button in pinButtons {
            button.isUserInteractionEnabled = canInteract
        }
    }

    @objc func backButtonTapped() {
        if let d = self.delegate {
            d.backPressed()
        }
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
	
    
    
    func setLabel(label: String) {
    	self.message = label
        if let m = messageView {
        	m.text = label
		}
    }
    
    private func update_display() {
        let size = input.count
        for i in 0...5 {
            if (i+1 <= size) {
                displayViews[i].backgroundColor = UIColor(red:0, green:0.7, blue:0.8, alpha:1)
            } else {
                displayViews[i].backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
            }
        }
    }
    
    func onWrongInput() {
        clearDisplay()
        shake_display()
    }
    
    func clearDisplay() {
        input = ""
        update_display()
    }
    
    func shake_display() {
        let keypath = "position"
        let animation = CABasicAnimation(keyPath: keypath)
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: inputContainer.center.x - 10, y: inputContainer.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: inputContainer.center.x + 10, y: inputContainer.center.y))
        inputContainer.layer.add(animation, forKey: keypath)
    }
    
    @IBAction func onButtonPress(_ sender: UIButton) {
        if (input.count < 6) {
            if let p = sender.title(for: .normal) {
                input += p
            }
        }
        update_display()
        if (input.count == 6) {
            delegate.pinEntered(pin: input)
        }
    }
    @IBAction func onDeletePress(_ sender: UIButton) {
        if (input.count > 0) {
            input.remove(at: input.index(before: input.endIndex))
        }
        update_display()
    }
}
