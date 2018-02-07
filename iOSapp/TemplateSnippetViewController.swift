//
//  TemplateSnippetViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 2/6/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

class TemplateSnippetViewController : UIViewController
{
    var color : UIColor = UIColor.white
    
    override func viewDidLoad()
    {
        self.view.backgroundColor = color
        print("in template")
    }
}
