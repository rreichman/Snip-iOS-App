//
//  AppDelegate.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/19/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

// Using this manual to submit the app
// https://www.youtube.com/watch?v=tnbOcpwJGa8

// To allow non-SSL communication, remove this from plist: <key>NSAppTransportSecurity</key><dict><key>NSAllowsArbitraryLoads</key><true/></dict>

import UIKit
import Fabric
import Crashlytics
import Mixpanel
import FacebookCore
import FBSDKCoreKit
import FacebookLogin
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var enteredBackgroundTime : Date = Date(timeIntervalSince1970: 0)
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        print("in application from URL " + url.absoluteString)
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as! String?, annotation: options[.annotation])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        print("started app \(Date())")
        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
        
        application.statusBarStyle = .lightContent
        
        Fabric.with([Crashlytics.self])
        Mixpanel.initialize(token: "45b15bed6d151b50d737789c474c9b66")
        Mixpanel.mainInstance().identify(distinctId: getUniqueDeviceID())
        
        if (launchOptions != nil)
        {
            let userActivityDictionary : [String : Any] = launchOptions![UIApplicationLaunchOptionsKey.userActivityDictionary] as! [String : Any]
            let userActivityKey = userActivityDictionary["UIApplicationLaunchOptionsUserActivityKey"]
            let userActivity : NSUserActivity = userActivityKey as! NSUserActivity
            
            let openingViewController : OpeningSplashScreenViewController = (window?.rootViewController) as! OpeningSplashScreenViewController
            openingViewController._snipRetrieverFromWeb.setFullUrlString(urlString: (userActivity.webpageURL?.absoluteString)!, query: "")
        }
        
        RealmManager.instance = RealmManager()
        
        print("app init done \(Date())")
        
        // Override point for customization after application launch.
        //return true
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool
    {
        print("User Activity: ")
        print(Date().timeIntervalSince1970 - enteredBackgroundTime.timeIntervalSince1970)
        
        window?.rootViewController?.restoreUserActivityState(userActivity)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        print("about to be unactive")
        
        enteredBackgroundTime = Date()
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        print("enter background")
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
        print("did become active \(Date())")
        
        FBSDKAppEvents.activateApp()
        AppEventsLogger.activate(application)
        Logger().logAppBecameActive()
        
        let currentTime : Date = Date()
        
        let wasAppLongInBackground : Bool = currentTime.seconds(from: enteredBackgroundTime) > SystemVariables().SECONDS_APP_IS_IN_BACKGROUND_BEFORE_REFRESH
        // Making sure that it's not the initial time of the program.
        let didWeEverEnterBackground : Bool = currentTime.seconds(from: enteredBackgroundTime) < 86400 * 3000
        
        print("Current URL in become active is \(WebUtils.shared.currentURLString)")
        
        let isComingFromSpecificPost : Bool = (WebUtils.shared.currentURLString.range(of: "/post/") != nil)
        
        if wasAppLongInBackground && didWeEverEnterBackground && !isComingFromSpecificPost
        {
            print("back to opening screen")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = storyboard.instantiateInitialViewController()
        }
        print("done did become active \(Date())")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        print("about to terminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

