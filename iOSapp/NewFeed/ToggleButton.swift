//
//  ToggleButton.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

enum ButtonValue {
    case off
    case fractional(value: Double)
    case on
}


@IBDesignable
class ToggleButton: UIButton {
    
    @IBInspectable @objc dynamic var onImage: UIImage? = nil {
        didSet {
            let f = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
            onImageView = buildImageView(image: onImage, frame: f)
            if self.imageInsets != nil {
                addImageViewConstraints()
            }
            self.addSubview(onImageView)
        }
    }
    @IBInspectable @objc dynamic var offImage: UIImage? = nil {
        didSet {
            self.setImage(offImage, for: .normal)
        }
    }
    var value: ButtonValue = .off
    var onImageView: UIImageView!
    var onButtonPress: ((ButtonValue) -> Void)?
    var imageInsets: UIEdgeInsets?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if onImage != nil {
            initButton(imageFrame: frame)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton(imageFrame: self.frame)
    }
    
    convenience init(onImage: UIImage, offImage: UIImage, imageFrame: CGRect, imageInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)) {
        let frame_with_insets = CGRect(x: 0.0, y: 0.0, width: imageFrame.width + imageInsets.left + imageInsets.right, height: imageFrame.height + imageInsets.top + imageInsets.bottom)
        self.init(frame: frame_with_insets)
        self.onImage = onImage
        self.offImage = offImage
        self.imageInsets = imageInsets
        initButton(imageFrame: imageFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.imageView != nil {

            self.setImageForValue(value: self.value)
        }
    }
    
    func buildImageView(image: UIImage?, frame: CGRect) -> UIImageView {
        let iv = UIImageView(frame: frame)
        iv.contentMode = .scaleAspectFit
        iv.image = image
        iv.isOpaque = false
        iv.alpha = 0.0
        return iv
    }
    
    func initButton(imageFrame: CGRect) {
        if let insets = self.imageInsets {
            self.imageEdgeInsets = insets
        }
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.setImage(offImage, for: .normal)
        if onImage != nil {
            onImageView = buildImageView(image: self.onImage, frame: imageFrame)
            self.addSubview(onImageView)
            addImageViewConstraints()
        }
    }
    
    func addImageViewConstraints() {
        guard let insets = self.imageInsets else { return }
        onImageView.translatesAutoresizingMaskIntoConstraints = false
        self.onImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top).isActive = true
        self.onImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom).isActive = true
        self.onImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left).isActive = true
        self.onImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.right).isActive = true
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if onImageView != nil {
            self.bringSubview(toFront: onImageView)
        }
    }
    
    func bind(on_state: Bool, value_changed: @escaping (ButtonValue) -> Void) {
        self.value = (on_state ? .on : .off)
        setImageForValue(value: self.value)
        self.onButtonPress = value_changed
    }
    
    func setValue(to value: ButtonValue) {
        setImageForValue(value: value)
        self.value = value
    }
    
    func setImageForValue(value: ButtonValue) {
        var alpha: CGFloat!
        var off_alpha: CGFloat!
        switch value {
        case .off:
            off_alpha = 1.0
            alpha = 0.0
        case .fractional(let value):
            off_alpha = CGFloat.init(1.0 - value)
            alpha = CGFloat.init(value)
        case .on:
            off_alpha = 0.0
            alpha = 1.0
        }
        self.imageView?.alpha = off_alpha
        onImageView.alpha = alpha
    }
    @objc func buttonPressed() {
        switch self.value {
        case .off:
            self.value = .on
        case .fractional:
            self.value = .on
        case .on:
            self.value = .off
        }
        setImageForValue(value: self.value)
        if let f = self.onButtonPress {
            f(self.value)
        }
    }
}
