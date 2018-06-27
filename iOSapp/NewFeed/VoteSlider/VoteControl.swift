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
    
    weak var leftButton: ToggleButton?
    weak var rightButton: ToggleButton?
    weak var slider: VoteSlider?
    weak var delegate: VoteControlDelegate?
    //This bullshit isnt worth the 200 extra lines you need to write (@IBInspectable)
    
    @IBInspectable var emptyLeftImage: UIImage = UIImage() {
        didSet {
            guard let leftButton = self.leftButton else { return }
            leftButton.offImage = emptyLeftImage
        }
    }
    @IBInspectable var filledLeftImage: UIImage = UIImage() {
        didSet {
            guard let leftButton = self.leftButton else { return }
            leftButton.onImage = filledLeftImage
        }
    }
    
    @IBInspectable var emptyRightImage: UIImage = UIImage() {
        didSet {
            guard let rightButton = self.rightButton else { return }
            rightButton.offImage = emptyRightImage
        }
    }
    @IBInspectable var filledRightImage: UIImage = UIImage() {
        didSet {
            guard let rightButton = self.rightButton else { return }
            rightButton.onImage = filledRightImage
        }
    }
    
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
        let leftButton = buildButton(emptyImage: self.emptyLeftImage, filledImage: self.filledLeftImage)
        leftButton.onButtonPress = { [unowned self] newValue in
            guard let slider = self.slider, let rightButton = self.rightButton else { return }
            var overall_vote_value: Double!
            switch newValue {
            case .off:
                slider.value = 0.0
                overall_vote_value = 0.0
            case .on:
                slider.value = -1.0
                switch rightButton.value {
                case .off:
                    break
                default:
                    rightButton.setValue(to: .off)
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
        let rightButton = buildButton(emptyImage: self.emptyRightImage, filledImage: self.filledRightImage)
        rightButton.onButtonPress = { [unowned self] newValue in
            guard let slider = self.slider, let leftButton = self.leftButton else { return }
            var overall_vote_value: Double!
            switch newValue {
            case .off:
                slider.value = 0.0
                overall_vote_value = 0.0
            case .on:
                slider.value = 1.0
                overall_vote_value = 1.0
                switch leftButton.value {
                case .off:
                    break
                default:
                    leftButton.setValue(to: .off)
                }
            case .fractional:
                //will never happen
                break
            }
            if let d = self.delegate {
                d.voteValueSet(to: overall_vote_value)
            }
        }
        var slider = VoteSlider()
        slider.setThumbImage(UIImage(named: "blueSliderThumb"), for: .normal)
        slider.setThumbImage(UIImage(named: "blueSliderThumb"), for: .highlighted)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.maximumValue = 1.0
        slider.minimumValue = -1.0
        slider.value = 0.0
        slider.addTarget(self, action: #selector(onValueContinuous), for: .valueChanged)
        slider.addTarget(self, action: #selector(onValueChanged), for: .touchUpInside)
        self.leftButton = leftButton
        self.rightButton = rightButton
        self.slider = slider
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(slider)
        setConstraints()
    }
    
    func bind(voteValue: Double) {
        guard let slider = self.slider else { return }
        slider.value = Float.init(voteValue)
        onValueContinuous()
    }
    
    @objc func onValueContinuous() {
        guard let slider = self.slider, let leftButton = self.leftButton, let rightButton = self.rightButton else { return }
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
        guard let d = self.delegate, let slider = self.slider else { return }
        d.voteValueSet(to: Double(exactly: slider.value)!)
    }
    
    private func setConstraints() {
        guard let slider = self.slider, let leftButton = self.leftButton, let rightButton = self.rightButton else { return }
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
        let button = ToggleButton(onImage: filledImage, offImage: emptyImage, buttonDimension: self.view_height, imageInsets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0))
        return button
    }
}

