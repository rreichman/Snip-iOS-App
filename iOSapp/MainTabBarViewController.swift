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
        
        tabBar.tintColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        let tabBarItems : [UITabBarItem] = tabBar.items!
        tabBarItems[0].image = #imageLiteral(resourceName: "home")
        tabBarItems[0].title = "Home"
        tabBarItems[0].tag = 0
        
        tabBarItems[1].image = #imageLiteral(resourceName: "wallet")
        tabBarItems[1].title = "Wallet"
        tabBarItems[1].tag = 1
        
        tabBarItems[2].image = #imageLiteral(resourceName: "myAccount")
        tabBarItems[2].title = "Me"
        tabBarItems[2].tag = 2
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        print("Tab bar selected")
        
        if (item.tag == 0)
        {
            let snippetsNavigationController : UINavigationController = viewControllers?[0] as! UINavigationController
            let currentViewController : GenericProgramViewController = snippetsNavigationController.viewControllers[snippetsNavigationController.viewControllers.count - 1] as! GenericProgramViewController
            
            if (!(currentViewController.viewControllerToReturnTo is GenericProgramViewController))
            {
                (currentViewController as! SnippetsTableViewController).operateHomeButtonAction()
            }
        }
    }
}
