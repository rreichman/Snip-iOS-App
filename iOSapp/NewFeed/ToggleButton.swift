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
    @IBInspectable var onImage: UIImage? = nil {
        didSet {
            guard let onImageView = self.onImageView else { return }
            onImageView.image = onImage
        }
    }
    
    @IBInspectable var offImage: UIImage? = nil {
        didSet {
            self.setImage(offImage, for: .normal)
        }
    }
    
    @IBInspectable var topImageInset: CGFloat = 0.0 {
        didSet {
            //updateConstraintsForDimensionChange()
        }
    }
    
    @IBInspectable var leftImageInset: CGFloat = 0.0 {
        didSet {
            //updateConstraintsForDimensionChange()
        }
    }
    
    @IBInspectable var bottomImageInset: CGFloat = 0.0 {
        didSet {
             updateConstraintsForDimensionChange()
        }
    }
    
    
    @IBInspectable var rightImageInset: CGFloat = 0.0 {
        didSet {
            //updateConstraintsForDimensionChange()
        }
    }
    
    var imageInsets: UIEdgeInsets {
        set {
            self.imageEdgeInsets = newValue
            topImageInset = newValue.top
            leftImageInset = newValue.left
            rightImageInset = newValue.right
            bottomImageInset = newValue.bottom
        }
        get {
            return UIEdgeInsets(top: topImageInset, left: leftImageInset, bottom: bottomImageInset, right: rightImageInset)
        }
    }
    
    @IBInspectable var buttonDimensions: CGFloat = 0.0 {
        didSet {
            //updateConstraintsForDimensionChange()
        }
    }
    var value: ButtonValue = .off
    weak var onImageView: UIImageView?
    var onButtonPress: ((ButtonValue) -> Void)?
    
    
    
    var buttonViewHeightConstraint: NSLayoutConstraint?
    var buttonViewWidthConstraint: NSLayoutConstraint?
    
    var imageViewHeightConstraint: NSLayoutConstraint?
    var imageViewWidthConstraint: NSLayoutConstraint?
    var imageViewTopConstraint: NSLayoutConstraint?
    var imageViewLeadingConstraint: NSLayoutConstraint?
    var imageViewTrailingConstraint: NSLayoutConstraint?
    var imageViewBottomConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    convenience init(onImage: UIImage, offImage: UIImage, buttonDimension: CGFloat, imageInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)) {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: buttonDimension, height: buttonDimension))
        self.buttonDimensions = buttonDimension
        self.onImage = onImage
        self.offImage = offImage
        self.imageInsets = imageInsets
        initButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.imageView != nil {
            self.setImageForValue(value: self.value)
        }
    }
    
    
    
    // All inits eventually call this
    func initButton() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imageEdgeInsets = self.imageInsets
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.setImage(offImage, for: .normal)
        buildOverlyingImageView()
        updateConstraintsForDimensionChange()
        self.setNeedsLayout()
        self.layoutSubviews()
    }
    // 1. Build the UIImageView
    // 2. Add the UIImageView as a subview
    func buildOverlyingImageView() {
        let onImageView = buildImageView(image: self.onImage)
        self.addSubview(onImageView)
        self.onImageView = onImageView
    }
    
    func buildImageView(image: UIImage?) -> UIImageView {
        let iv = UIImageView(frame: self.frame)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = image
        iv.isOpaque = false
        iv.alpha = 0.0
        return iv
    }
    
    func updateConstraintsForDimensionChange() {
        self.imageViewHeightConstraint?.isActive = false
        self.imageViewWidthConstraint?.isActive = false
        self.imageViewTopConstraint?.isActive = false
        self.imageViewLeadingConstraint?.isActive = false
        self.imageViewTrailingConstraint?.isActive = false
        self.imageViewBottomConstraint?.isActive = false
        
        if let onImageView = self.onImageView {
            self.imageViewHeightConstraint = onImageView.heightAnchor.constraint(equalToConstant: self.buttonDimensions - self.imageInsets.top - self.imageInsets.bottom)
            self.imageViewHeightConstraint!.isActive = true
            
            self.imageViewWidthConstraint = onImageView.widthAnchor.constraint(equalToConstant: self.buttonDimensions - self.imageInsets.left - self.imageInsets.right)
            self.imageViewWidthConstraint!.isActive = true
            
            self.imageViewTopConstraint = onImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.imageInsets.top)
            self.imageViewTopConstraint!.isActive = true
            
            self.imageViewBottomConstraint = onImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.imageInsets.bottom)
            self.imageViewBottomConstraint!.isActive = true
            
            self.imageViewLeadingConstraint = onImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.imageInsets.left)
            self.imageViewLeadingConstraint!.isActive = true
            
            self.imageViewTrailingConstraint = onImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.imageInsets.right)
            self.imageViewTrailingConstraint!.isActive = true
        }
        
        if let buttonHeight = self.buttonViewHeightConstraint, let buttonWidth = self.buttonViewWidthConstraint {
            buttonHeight.isActive = false
            buttonWidth.isActive = false
        }
        
        self.buttonViewWidthConstraint = self.widthAnchor.constraint(equalToConstant: self.buttonDimensions)
        self.buttonViewWidthConstraint!.isActive = true
        
        self.buttonViewHeightConstraint = self.heightAnchor.constraint(equalToConstant: self.buttonDimensions)
        self.buttonViewHeightConstraint!.isActive = true
        
        self.imageEdgeInsets = self.imageInsets
        
        self.setNeedsLayout()
        self.layoutSubviews()
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        guard let onImageView = self.onImageView else { return }
        self.bringSubview(toFront: onImageView)
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
        guard let onImageView = self.onImageView else { return }
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
