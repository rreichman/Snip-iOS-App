//
//  ViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/9/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class MyViewController : UIViewController
{
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        label.numberOfLines = 0
        label.text = "abcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabc-end"
        label.sizeToFit()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
