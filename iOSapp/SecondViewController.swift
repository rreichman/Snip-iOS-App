//
//  SecondViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/23/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    @IBAction func buttonToHomeScreen(_ sender: Any) {
        self.performSegue(withIdentifier: "firstViewSegueFromSecond", sender : self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("second view has loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
