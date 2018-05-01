//
//  GenericNavigationController.swift
//  iOSapp
//
//  Created by Ran Reichman on 4/10/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

class GenericNavigationController : UINavigationController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
