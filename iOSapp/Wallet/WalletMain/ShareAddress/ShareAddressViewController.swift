//
//  ShareAddressViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/27/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol ShareAddressDelegate: class {
    
}

class ShareAddressViewController: UIViewController {
    let presenterDelegate = TransitionDelegate()
    var public_address: String?
    
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var qrCodeView: UIImageView!
    
    override func viewDidLoad() {
        //setPublicAddress(address: "0x7a8F2734D08927b7A569e4887b81f714Ba1A82AA")
        if let p = public_address {
            setPublicAddress(address: p)
        }
        
    }
    func setCornerRadius(frame: CGRect) {
        let radius = 10
        let path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        containerView.layer.mask = mask
    }
    func setPublicAddress(address: String) {
        self.public_address = address
        if qrCodeView != nil {
            buildAndSetQRCode(from: address)
        }
        if let label = addressLabel {
            label.text = address
        }
    }
    
    func buildAndSetQRCode(from address: String) {
        let context = CIContext()
        let data = address.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 7, y: 7)
            if let output = filter.outputImage?.transformed(by: transform), let cgImage = context.createCGImage(output, from: output.extent) {
                qrCodeView.image = UIImage(cgImage: cgImage)
            }
        }
    }
    @IBAction func swipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onCopyButton() {
    }
    @IBAction func onOtherShare() {
    }
    @IBAction func onClose() {
        dismiss(animated: true, completion: nil)
    }
}
