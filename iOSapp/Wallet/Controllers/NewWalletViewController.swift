//
//  NewWalletViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol NewWalletViewDelegate: class {
    func onDonePressed()
}

class NewWalletViewController : UIViewController {
    
    @IBOutlet var doneButtonConstraint: NSLayoutConstraint!
    @IBOutlet var phraseLabel: UILabel!
    
    var delegate: NewWalletViewDelegate!
    var phrase: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        if let s = phrase {
            phraseLabel.text = s
        }
    }
    
    func setPhrase(phrase: String) {
        if viewIfLoaded != nil {
            phraseLabel.text = phrase
        }
        self.phrase = phrase
    }
    
    func showError(phrase:String) {
        
    }
    
    func setDelegate(delegate: NewWalletViewDelegate) {
        self.delegate = delegate
    }

    @IBAction func onDonePressed() {
        delegate.onDonePressed()
    }
}
