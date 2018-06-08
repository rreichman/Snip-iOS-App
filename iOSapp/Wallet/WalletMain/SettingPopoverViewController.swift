//
//  SettingPopoverViewController.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/11/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol SettingPopoverViewDelegate {
    func onRemoveRequested()
    func onChangeRequested()
}

class SettingPopoverViewController : UIViewController {
    @IBOutlet var removeButton: UIButton!
    @IBOutlet var changeButton: UIButton!
    var delegate: SettingPopoverViewDelegate!
    override func viewDidLoad() {
        //pass
        self.view.layer.cornerRadius = 5
    }
    
    //Updating the popover size
    override var preferredContentSize: CGSize {
        get {
            let size = CGSize(width: 150, height: 108)
            return size
        }
        set {
            super.preferredContentSize = newValue
        }
    }
    
    @IBAction func onRemove(_ sender: UIButton) {
        guard let d = delegate else {return}
        dismiss(animated: true, completion: nil)
        d.onRemoveRequested()
    }
    @IBAction func onChange(_ sender: UIButton) {
        guard let d = delegate else {return}
        dismiss(animated: true, completion: nil)
        d.onChangeRequested()
    }
    
    //Setup the ViewController for popover presentation
    func updatePopOverViewController(_ button: UIButton?, with delegate: AnyObject?) {
        guard let button = button else { return }
        modalPresentationStyle = .popover
        popoverPresentationController?.permittedArrowDirections = .up
        popoverPresentationController?.backgroundColor = UIColor.white
        popoverPresentationController?.sourceView = button
        popoverPresentationController?.sourceRect = button.bounds
        popoverPresentationController?.delegate = delegate as! UIPopoverPresentationControllerDelegate
    }
}
