//
//  ExpandedImageViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/14/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import Nuke

class ExpandedImageViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var sourceLabel: UITextView!
    
    var imageUrl: URL?
    var sourceTitle: String?
    var sourceLink: String?
    
    
    override func viewDidLoad() {
        
        self.bindView(imageUrl: imageUrl, sourceTitle: sourceTitle, sourceLink: sourceLink)
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTap)))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTap)))
        let padding = UIScreen.main.bounds.height * 0.2
        
        /**
        let top_constraint = imageView.topAnchor.constraint(greaterThanOrEqualTo: self.view.topAnchor, constant: padding)
        top_constraint.isActive = true
        let bottom_constraint = imageView.bottomAnchor.constraint(greaterThanOrEqualTo: self.view.bottomAnchor, constant: -padding)
        bottom_constraint.isActive = true
        **/
    }
    
    @objc func backgroundTap() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func imageTap() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func bind(imageUrl: URL, sourceTitle: String, sourceLink: String) {
        self.imageUrl = imageUrl
        self.sourceTitle = sourceTitle
        self.sourceLink = sourceLink
        
        bindView(imageUrl: imageUrl, sourceTitle: sourceTitle, sourceLink: sourceLink)
    }
    
    func bindView(imageUrl: URL?, sourceTitle: String?, sourceLink: String?) {
        guard let _ = imageUrl, let _ = self.imageView else { return }
        
        Nuke.loadImage(with: imageUrl!, into: self.imageView)
        
        guard let url = URL(string: sourceLink!) else { return }
        guard let richText = NSMutableAttributedString(htmlString: sourceTitle!) else { return }
        sourceLabel.tintColor = UIColor.white
        sourceLabel.isUserInteractionEnabled = true
        
        let attributes: [NSAttributedStringKey : Any] =
            [
             .foregroundColor: UIColor.white,
             .font: UIFont.lato(size: 15),
             .link: url]
        richText.addAttributes(attributes, range: NSMakeRange(0, richText.length))
        sourceLabel.attributedText = richText
        
    }
}

extension ExpandedImageViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ExpandedImagePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension ExpandedImageViewController {
    static func showExpandedImage(for post: Post, presentingVC: UIViewController) {
        guard let image = post.image, let url = URL(string: image.imageUrl) else { return }
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ExpandedImageViewController") as! ExpandedImageViewController
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc
        vc.bind(imageUrl: url, sourceTitle: image.imageDescription, sourceLink: image.imageUrl)
        presentingVC.present(vc, animated: false, completion: nil)
    }
}
