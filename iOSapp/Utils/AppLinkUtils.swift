//
//  AppLinkUtils.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/14/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Crashlytics

class AppLinkUtils {
    static func shouldOpenLinkInApp(link: URL) -> Bool {
        if let host = link.host {
            print("Link clicked with host \(host)")
            return host.contains("snip.today")
        }
        return false
    }
    
    
    // Helper function for links clicked in the body of snippets that point to another snippet. Not used for universal links outside of the app
    static func resolveAndPushAppLink(link: String, navigationController: UINavigationController) {
        let realm = RealmManager.instance.getMemRealm()
        let _ = SnipRequests.instance.getPostFromAppLink(url: link)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (post) in
                try! realm.write {
                    realm.add(post, update: true)
                }
                let postCoordinator = PostDetailCoordinator(navigationController: navigationController, post: post, mode: .none)
                postCoordinator.start()
            }) { (err) in
                print("Error resolving post from deep link: \(err.localizedDescription)")
                Crashlytics.sharedInstance().recordError(err)
            }
    }
}
