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
    
	@IBOutlet var doneButton: UIButton!
	var delegate: NewWalletViewDelegate!
    var phrase: String?
    
    var phraseGenerated: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        if let s = phrase {
            phraseLabel.text = s
        }
		
        setInteraction(canInteract: phraseGenerated)
		
    }
    
    func setInteraction(canInteract: Bool) {
        if let db = doneButton {
            db.isUserInteractionEnabled = canInteract
            let color = (canInteract ? UIColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1.0) : UIColor(red: 0.8, green: 0.94, blue: 0.96, alpha: 1.0))
            db.backgroundColor = color
        }
        
    }
    
    func setPhrase(phrase: String) {
        if viewIfLoaded != nil {
            phraseLabel.text = phrase
        }
        setInteraction(canInteract: true)
        self.phrase = phrase
        self.phraseGenerated  = true
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
