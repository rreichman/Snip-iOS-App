//
//  FixBackSwipeRecognizer.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/15/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class FixBackSwipeRecognizer: UIGestureRecognizer {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
