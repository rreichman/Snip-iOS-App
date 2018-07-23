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
import UserNotifications
import Firebase
import Nuke


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var enteredBackgroundTime : Date = Date(timeIntervalSince1970: 0)
    var coordinator: AppCoordinator!
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("AppDelegate.open with url \(url.absoluteString)")
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as! String?, annotation: options[.annotation])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("Appdelegate.didFinishLaunchingWithOptions")
        NotificationManager.instance.appLaunchCount += 1
        application.statusBarStyle = .lightContent
        if #available(iOS 10, *) {
            UICollectionView.appearance().isPrefetchingEnabled = false
        }
        
        Mixpanel.initialize(token: "45b15bed6d151b50d737789c474c9b66")
        let uuid: UUID? = UIDevice.current.identifierForVendor
        let uuid_string = (uuid == nil ? "" : uuid!.uuidString)
        Mixpanel.mainInstance().identify(distinctId: uuid_string)
        FirebaseApp.configure()
        //Messaging.messaging().shouldEstablishDirectChannel = true
        self._registerForRemoteNotifications(application: application)
        self.listenForDirectChannelStateChanges()
        RealmManager.instance = RealmManager()
        
        SnipLoggerRequests.instance.postDeviceID()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.coordinator = AppCoordinator(window, launchOptions: launchOptions)
        self.window = window
        coordinator.start()
        
        print("app init done \(Date())")
        Fabric.with([Crashlytics.self])
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        print("AppDelegate.continueUserActivity")
        self.coordinator.handleDeepLink(userActivity: userActivity)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("about to be unactive")
        
        enteredBackgroundTime = Date()
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("enter background")
        //Logger().logAppEnteredBackground()
        
        enteredBackgroundTime = Date()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("enter foreground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("AppDelegate.applicationDidBecomeActive")
        
        FBSDKAppEvents.activateApp()
        AppEventsLogger.activate(application)
        //Logger().logAppBecameActive()
        
        let currentTime : Date = Date()
        
        let wasAppLongInBackground : Bool = currentTime.seconds(from: enteredBackgroundTime) > SystemVariables().SECONDS_APP_IS_IN_BACKGROUND_BEFORE_REFRESH
        // Making sure that it's not the initial time of the program.
        let didWeEverEnterBackground : Bool = currentTime.seconds(from: enteredBackgroundTime) < 86400 * 3000
        
        coordinator.applicationDidBecomeActive(didWeEverEnterBackground, wasAppLongInBackground)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("about to terminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //if let messageID = userInfo[gcmMessageIDKey] {
        //    print("Message ID: \(messageID)")
        //}
        
        // Print full message.
        print("AppDelegate.didReceiveRemoteNotification(:completionhandler) \(userInfo)")
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func _registerForRemoteNotifications(application: UIApplication) {
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            
            application.registerForRemoteNotifications()
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    private func setNukeShareImageLoadingOptions() {
        let options = ImageLoadingOptions(transition:
            ImageLoadingOptions.Transition.fadeIn(duration: 0.33),
            contentModes: .init(
                success: .scaleAspectFill,
                failure: .center,
                placeholder: .center
            )
        )
        ImageLoadingOptions.shared = options
    }
    
    private func subscribeToDevTopic() {
        //Messaging.messaging().shouldEstablishDirectChannel = true
        Messaging.messaging().subscribe(toTopic: "dev") { (err) in
            print("Subscribed to dev topic, possible error subscribing \(err)")
        }
    }
    
    func handleNotificationData(userInfo: [AnyHashable : Any]) {
        guard let snippet_url = userInfo["snippet_url"] as? String else {
            print("unable to extract a snippet url from notification data")
            return
        }
        self.coordinator.showPostFromNotification(link: snippet_url)
        
        guard let notificationIdString = userInfo["id"] as? String, let notificationId = Int(notificationIdString) else {
            print("Unable to find notification ID from the notification data")
            return
        }
        
        NotificationRequests.instance.logNotificationClicked(notificationId: notificationId)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase sent a new registration token, saving and sending.\nToken: \(fcmToken)")
        NotificationManager.instance.saveAndSendRegistrationToken(registrationToken: fcmToken)
        #if MAIN
        print("Subscribing to main topic")
        #else
        print("Subscribing to dev topic")
        self.subscribeToDevTopic()
        #endif
        
    }
    //This is not working at all for some reason.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("MessagingDelegate.didReceive() \(remoteMessage)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    //This is only called when a notification has a notification block, will not work for data only notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("UNUserNotificationCenterDelegate.willPresent \(notification)")
        completionHandler([.alert])
    }
    
    //Called when coming back to foreground (or already there) from a notification with a notification block
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("UNUserNotificationCenterDelegate.didReceive \(response)")
        
        let data = response.notification.request.content.userInfo
        completionHandler()
        handleNotificationData(userInfo: data)
    }
}

extension AppDelegate {
    func listenForDirectChannelStateChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(onMessagingDirectChannelStateChanged(_:)), name: .MessagingConnectionStateChanged, object: nil)
    }
    
    @objc func onMessagingDirectChannelStateChanged(_ notification: Notification) {
        print("Is FCM Direct Channel Established: \(Messaging.messaging().isDirectChannelEstablished)")
    }
}

