//
//  AppCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/17/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Crashlytics

class AppCoordinator: Coordinator {
    let disposeBag: DisposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    var window: UIWindow!
    var userActivity: NSUserActivity!
    var rootController: OpeningSplashScreenViewController!
    var tabCoordinator: TabCoordinator!
    init(_ window: UIWindow, rootController: OpeningSplashScreenViewController) {
        //self.userActivity = userActivity
        rootController.delegate = self
        self.window = window
        self.rootController = rootController
        window.rootViewController = rootController
        window.makeKeyAndVisible()
    }
    
    func start() {
        loadMainFeed()
    }
    
    func loadMainFeed() {
        let realm = RealmManager.instance.getMemRealm()
        SnipRequests.instance.getMain()
            .timeout(5, scheduler: MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] (catList) in
                try! realm.write {
                    for category in catList {
                        realm.add(category, update: true)
                    }
                }
                print("Pre-loaded \(catList.count) categories")
                if let coordinator = self {
                    coordinator.onPreLoadingFinished()
                }
                
            }) { [weak self] (err) in
                print("Error on feed preload \(err)")
                if let timeoutError = err as? RxError {
                    switch timeoutError {
                    case .timeout:
                        print("Preload of feed failed")
                    default:
                        print("general RxError: \(timeoutError.localizedDescription)")
                    }
                    
                }
                Crashlytics.sharedInstance().recordError(err)
                //Continue anyway, this is just a preload
                if let coordinator = self {
                    coordinator.onPreLoadingFinished()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func onPreLoadingFinished() {
        self.tabCoordinator = TabCoordinator(rootController)
        tabCoordinator.start()
    }
    
    func didFinishLaunchingWithOptions(options: [UIApplicationLaunchOptionsKey: Any]?) {
        print("AppCoordinator.didFinishLaunchingWithOptions")
        if let o = options {
            let userActivityDictionary : [String : Any] = o[UIApplicationLaunchOptionsKey.userActivityDictionary] as! [String : Any]
            let userActivityKey = userActivityDictionary["UIApplicationLaunchOptionsUserActivityKey"]
            let userActivity : NSUserActivity = userActivityKey as! NSUserActivity
            print("didFinishLaunchingWithOptions found UIApplicationLaunchOptions")
            
            
            /**
            rootController._snipRetrieverFromWeb.setFullUrlString(urlString: (userActivity.webpageURL?.absoluteString)!, query: "")
            **/
        }
    }
    
    func handleDeepLink(userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            print("Attempting to fetch post from deep link \(url.absoluteString)")
            tabCoordinator.showPostFromDeepLink(url: url.absoluteString)
        }
    }
    
    func applicationDidBecomeActive(_ fromBackground: Bool, _ longBackground: Bool, _ fromPost: Bool) {
        if fromBackground && longBackground && !fromPost {
            let rc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! OpeningSplashScreenViewController
            self.window.rootViewController = rc
            self.rootController = rc
            loadMainFeed()
        }
    }
    
}

extension AppCoordinator: OpeningSplashScreenViewDelegate {
    func restoreUserActivityState(_ userActivity: NSUserActivity) {
        handleDeepLink(userActivity: userActivity)
    }
    
    
}
