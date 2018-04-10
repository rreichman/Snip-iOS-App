//
//  MainTabBarViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 4/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

class MainTabBarViewController : UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let tabBarItems : [UITabBarItem] = tabBar.items!
        tabBarItems[0].image = #imageLiteral(resourceName: "home")
        tabBarItems[0].title = "Home"
        
        tabBarItems[1].image = #imageLiteral(resourceName: "wallet")
        tabBarItems[1].title = "Wallet"
        
        tabBarItems[2].image = #imageLiteral(resourceName: "myAccount")
        tabBarItems[2].title = "Me"
    }
}
