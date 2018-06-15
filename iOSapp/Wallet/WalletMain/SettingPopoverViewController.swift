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
        //Not the right place for this self.view.superview?.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.superview?.layer.cornerRadius = 5
        super.viewWillAppear(animated)
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
        popoverPresentationController?.sourceRect = CGRect(x: button.bounds.origin.x, y: button.bounds.origin.y, width: button.bounds.width, height: button.bounds.height)//button.bounds
        //popoverPresentationController?.popoverLayoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        popoverPresentationController?.delegate = delegate as! UIPopoverPresentationControllerDelegate
    }
}
