//
//  AppDelegate.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/19/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

// Using this manual to submit the app
// https://www.youtube.com/watch?v=tnbOcpwJGa8

// TODO:: Before publishing, remove this from plist: <key>NSAppTransportSecurity</key><dict><key>NSAllowsArbitraryLoads</key><true/></dict>

import UIKit
import Fabric
import Crashlytics
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var enteredBackgroundTime : Date = Date(timeIntervalSince1970: 0)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        print("start")
        Fabric.with([Crashlytics.self])
        Mixpanel.initialize(token: "45b15bed6d151b50d737789c474c9b66")
        Mixpanel.mainInstance().identify(distinctId: getUniqueDeviceID())
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        print("about to be unactive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        print("enter backdground")
        Logger().logAppEnteredBackground()
        
        enteredBackgroundTime = Date()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        print("enter foreground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        print("become active")
        Logger().logAppBecameActive()
        
        let currentTime : Date = Date()
        
        if (currentTime.seconds(from: enteredBackgroundTime)) > SystemVariables().SECONDS_APP_IS_IN_BACKGROUND_BEFORE_REFRESH
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = storyboard.instantiateInitialViewController()
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        print("about to terminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

