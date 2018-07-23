//
//  PostInteractionUtils.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/21/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class PostInteractionUtils {
    static func showPostShareActionSheet(postTitle: String, urlString: String, sourceView: UIView, presentingViewController: UIViewController) {
        guard let url = NSURL(string: urlString) else { return }
        let objects = ["Check out this snippet: \(postTitle)", url] as [ Any ]
        let activityVC = UIActivityViewController(activityItems: objects, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sourceView
        presentingViewController.present(activityVC, animated: true, completion: nil)
    }
}
