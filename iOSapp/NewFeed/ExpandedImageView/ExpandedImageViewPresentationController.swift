//
//  ExpandedImageViewPresentationController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/14/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
class ExpandedImagePresentationController: UIPresentationController {
    
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let vc = presentedViewController as! ExpandedImageViewController
        let height = UIScreen.main.bounds.height - 400
        //return containerView!.bounds.insetBy(dx: 30, dy: 30)
        
        //return CGRect(x:0, y: 100, width: UIScreen.main.bounds.width, height: height)
        return UIScreen.main.bounds
    }
}
