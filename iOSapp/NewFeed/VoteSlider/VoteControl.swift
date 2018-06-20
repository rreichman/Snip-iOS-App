//
//  VoteControl.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/18/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

protocol VoteControlDelegate: class {
    func voteValueSet(to: Double)
}

@IBDesignable
class VoteControl: UIView {
    
    var leftButton: ToggleButton!
    var rightButton: ToggleButton!
    var slider: VoteSlider!
    var delegate: VoteControlDelegate?
    //This bullshit isnt worth the 200 extra lines you need to write (@IBInspectable)
    
    @IBInspectable var emptyLeftImage: UIImage = UIImage()
    @IBInspectable var filledLeftImage: UIImage = UIImage()
    
    @IBInspectable var emptyRightImage: UIImage = UIImage()
    @IBInspectable var filledRightImage: UIImage = UIImage()
    
    
    private let view_height: CGFloat = 44.0
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: UIViewNoIntrinsicMetric, height: self.view_height)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForInterfaceBuilder() {
        setupDesignable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func setupDesignable() {
        initView()
    }
    
    func initView() {
        //self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        leftButton = buildButton(emptyImage: UIImage(named: "dislikeEmpty")!, filledImage: UIImage(named: "dislikeFilled")!)
        leftButton.onButtonPress = { newValue in
            var overall_vote_value: Double!
            switch newValue {
            case .off:
                self.slider.value = 0.0
                overall_vote_value = 0.0
            case .on:
                self.slider.value = -1.0
                switch self.rightButton.value {
                case .off:
                    break
                default:
                    self.rightButton.setValue(to: .off)
                }
                overall_vote_value = -1.0
            case .fractional:
                //will never happen
                break
            }
            if let d = self.delegate {
                d.voteValueSet(to: overall_vote_value)
            }
        }
        rightButton = buildButton(emptyImage: UIImage(named: "likeEmpty")!, filledImage: UIImage(named: "likeFilled")!)
        rightButton.onButtonPress = { newValue in
            var overall_vote_value: Double!
            switch newValue {
            case .off:
                self.slider.value = 0.0
                overall_vote_value = 0.0
            case .on:
                self.slider.value = 1.0
                overall_vote_value = 1.0
                switch self.leftButton.value {
                case .off:
                    break
                default:
                    self.leftButton.setValue(to: .off)
                }
            case .fractional:
                //will never happen
                break
            }
            if let d = self.delegate {
                d.voteValueSet(to: overall_vote_value)
            }
        }
        slider = VoteSlider()
        slider.setThumbImage(UIImage(named: "blueSliderThumb"), for: .normal)
        slider.setThumbImage(UIImage(named: "blueSliderThumb"), for: .highlighted)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.maximumValue = 1.0
        slider.minimumValue = -1.0
        slider.value = 0.0
        slider.addTarget(self, action: #selector(onValueContinuous), for: .valueChanged)
        slider.addTarget(self, action: #selector(onValueChanged), for: .touchUpInside)
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(slider)
        setConstraints()
    }
    
    func bind(voteValue: Double) {
        slider.value = Float.init(voteValue)
        onValueContinuous()
    }
    
    @objc func onValueContinuous() {
        if slider.value == 0.0 {
            leftButton.setValue(to: .off)
            rightButton.setValue(to: .off)
        } else if slider.value == 1.0 {
            leftButton.setValue(to: .off)
            rightButton.setValue(to: .on)
        } else if slider.value == -1.0 {
            leftButton.setValue(to: .on)
            rightButton.setValue(to: .off)
        } else if slider.value > 0.0 {
            leftButton.setValue(to: .off)
            rightButton.setValue(to: .fractional(value: Double(slider.value)))
        } else {
            leftButton.setValue(to: .fractional(value: Double(slider.value * -1)))
            rightButton.setValue(to: .off)
        }
    }
    
    @objc func onValueChanged() {
        if let d = self.delegate {
            d.voteValueSet(to: Double(exactly: slider.value)!)
        }
    }
    
    private func setConstraints() {
        leftButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
        leftButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0).isActive = true
        
        slider.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 0.0).isActive = true
        slider.centerYAnchor.constraint(equalTo: leftButton.centerYAnchor).isActive = true
        
        rightButton.leadingAnchor.constraint(equalTo: slider.trailingAnchor, constant: 0.0).isActive = true
        rightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0.0).isActive = true
        rightButton.topAnchor.constraint(equalTo: leftButton.topAnchor).isActive = true
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func buildButton(emptyImage: UIImage, filledImage: UIImage) -> ToggleButton {
        let button = ToggleButton(onImage: filledImage, offImage: emptyImage, imageFrame: CGRect(x: 0, y: 0, width: 24.0, height: 24.0), imageInsets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0))
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        //button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        return button
    }
}

