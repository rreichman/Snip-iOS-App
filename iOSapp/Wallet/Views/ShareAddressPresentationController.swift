//
//  ShareAddressPresentationController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/30/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class TransitionDelegate : NSObject, UIViewControllerTransitioningDelegate {
   
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ShareAddressPresentationController(presentedViewController:presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ShareAddressPresentationController(presentedViewController:presented, presenting: presenting)
    }
}



class ShareAddressPresentationController: UIPresentationController {
    let chrome = UIView()
    let chromeColor = UIColor(
        red:0.0,
        green:0.0,
        blue:0.0,
        alpha: 0.6)
    override var frameOfPresentedViewInContainerView: CGRect {
        let vc = presentedViewController as! ShareAddressViewController
        let height = vc.containerView.bounds.height
        return CGRect(x:0, y: self.containerView!.bounds.height - height, width: (self.containerView?.bounds.width)!, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        chrome.frame = containerView!.bounds
        chrome.alpha = 1.0
        chrome.backgroundColor = chromeColor
        containerView!.insertSubview(chrome, at: 0)
    }
    override func dismissalTransitionWillBegin() {
        self.chrome.removeFromSuperview()
    }
    
    override func containerViewWillLayoutSubviews() {
        chrome.frame = containerView!.bounds
        presentedView!.frame = frameOfPresentedViewInContainerView
    }
}
extension ShareAddressPresentationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //pass
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        let animationDuration = transitionDuration(using: transitionContext)
        //toViewController.view.transform = CGAffineTransform(translationX: (containerView.bounds.width), y: 0)
        toViewController.view.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        toViewController.view.layer.shadowColor = UIColor.black.cgColor
        toViewController.view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        toViewController.view.layer.shadowOpacity = 0.3
        toViewController.view.clipsToBounds = true
        
        containerView.addSubview((toViewController.view)!)
        
        UIView.animate(withDuration: animationDuration, animations: {
            toViewController.view.transform = .identity
        }, completion: { finished in transitionContext.completeTransition(finished)})
    }
    

}
