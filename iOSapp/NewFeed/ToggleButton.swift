//
//  ToggleButton.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class ToggleButton: UIButton {
    
    @IBInspectable @objc dynamic var onImage: UIImage? = nil
    @IBInspectable @objc dynamic var offImage: UIImage? = nil
    var on: Bool = false
    var toggle_func: ((Bool) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    
    func initButton() {
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    func bind(on_state: Bool, toggle_func: ((Bool) -> ())? ) {
        self.on = on_state
        self.toggle_func = toggle_func
        setImageForState(on_state: on_state)
    }
    
    func setState(on: Bool) {
        let img = on ? onImage : offImage
        self.setImage(img, for: .normal)
        self.on = on
    }
    
    func setImageForState(on_state: Bool) {
        let img_opt = on_state ? onImage : offImage
        guard let img = img_opt else { return }
        self.setImage(img, for: .normal)
    }
    @objc func buttonPressed() {
        on = !on
        setImageForState(on_state: on)
        if let f = self.toggle_func {
            f(on)
        }
    }
}
