//
//  ViewController.swift
//  test
//
//  Created by Ran Reichman on 10/20/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func buttonToNextScreen(_ sender: Any) {
        print("button click")
        self.performSegue(withIdentifier: "secondViewSegue", sender : self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("first view has loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
