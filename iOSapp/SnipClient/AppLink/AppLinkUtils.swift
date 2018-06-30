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

enum AppLinkAction {
    case openPost(slug: String)
    case followRedirect(url: URL)
    case showProfile
    case nothing
}

class AppLinkUtils {
    static func shouldOpenLinkInApp(link: URL) -> Bool {
        switch AppLinkUtils.routeAppLink(link: link) {
        case .nothing:
            return false
        default:
            return true
        }
        
    }
    
    static func routeAppLink(link: URL) -> AppLinkAction {
        guard let host = link.host else { return .nothing }
        if !host.hasSuffix("snip.today") { return .nothing }
        
        // Test for slug formatted links
        if let slug = AppLinkUtils.extractSlug(from: link) {
            return .openPost(slug: slug)
        }
        
        // Test for sendgrid email links
        if host == "em1.snip.today" {
            return .followRedirect(url: link)
        }
        return .nothing
    }
    
    static func extractSlug(from url: URL) -> String? {
        let path_components = url.pathComponents
        if path_components.count > 3 && path_components[0] == "/" && path_components[1] == "main" && path_components[2] == "post" {
            return path_components[3]
        }
        return nil
    }
    
    // Helper function for links clicked in the body of snippets that point to another snippet. Not used for universal links outside of the app
    
    static func resolveAndPushAppLink(link: String, navigationController: UINavigationController) {
        guard let url = URL(string: link) else {
            print("AppLinkUtils resolveAndPushAppLink called with an invalid url")
            return
        }
        let action = AppLinkUtils.routeAppLink(link: url)
        switch action {
        case .openPost(let slug):
            let realm = RealmManager.instance.getMemRealm()
            let _ = SnipRequests.instance.getPost(fromSlug: slug)
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
        default:
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
