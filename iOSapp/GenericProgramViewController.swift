//
//  GenericProgramViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 12/4/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class GenericProgramViewController : UIViewController
{
    var viewControllerToReturnTo : UIViewController = UIViewController()
    // Note - this is for cases where we don't want to create a new view controller but move to the previous one. Relevant for the login -> signup -> login flow
    var shouldPressBackAndNotSegue : Bool = false
    
    func segueBackToContent(alertAction: UIAlertAction)
    {
        navigationController?.popToViewController(viewControllerToReturnTo, animated: true)
    }
}
