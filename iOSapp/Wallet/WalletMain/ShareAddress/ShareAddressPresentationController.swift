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
    let chromeColor = UIColor(white: 0.5, alpha: 0.6) //gray dims the background
    
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let vc = presentedViewController as! ShareAddressViewController
        let height = vc.containerView.bounds.height
        //return containerView!.bounds.insetBy(dx: 30, dy: 30)
        
        return CGRect(x:0, y: self.containerView!.bounds.height - height, width: (self.containerView?.bounds.width)!, height: height).insetBy(dx: 6, dy: 0.0)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        chrome.frame = containerView!.bounds
        chrome.alpha = 0.0
        chrome.backgroundColor = chromeColor
        
        containerView!.insertSubview(chrome, at: 0)
        presentedViewController.transitionCoordinator!.animate(
            alongsideTransition: {context in
                self.chrome.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator!.animate(
            alongsideTransition: { context in
                self.chrome.alpha = 0.0
        },
            completion: {context in
                self.chrome.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        chrome.frame = containerView!.bounds
        presentedView!.frame = frameOfPresentedViewInContainerView
        (presentedViewController as! ShareAddressViewController).setCornerRadius(frame: CGRect(x: 0, y: 0, width: frameOfPresentedViewInContainerView.width, height: frameOfPresentedViewInContainerView.height))
    }
}
extension ShareAddressPresentationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Get everything you need
        let presentingViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let finalFrameForVC = transitionContext.finalFrame(for: presentingViewController)
        let containerView = transitionContext.containerView
        let bounds = UIScreen.main.bounds
        
        presentingViewController.view.frame = finalFrameForVC.offsetBy(dx: 0, dy: bounds.size.height)
        presentingViewController.view.alpha = 0.0
        containerView.addSubview(presentingViewController.view)
        
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: .curveEaseOut,animations: {
            presentingViewController.view.frame = finalFrameForVC
            presentingViewController.view.alpha = 1.0
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
        /*
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        let animationDuration = transitionDuration(using: transitionContext)
        //toViewController.view.transform = CGAffineTransform(translationX: (containerView.bounds.width), y: 0)
        toViewController.view.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        toViewController.view.clipsToBounds = true
        
        containerView.addSubview((toViewController.view)!)
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseOut, animations: {
            toViewController.view.transform = .identity
        }, completion: { finished in transitionContext.completeTransition(finished)})
         */
    }
    

}
