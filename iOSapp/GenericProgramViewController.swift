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
    
    func segueBackToContent(alertAction: UIAlertAction)
    {
        navigationController?.popToViewController(viewControllerToReturnTo, animated: true)
    }
}
