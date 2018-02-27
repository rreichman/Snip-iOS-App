//
//  SnippetMenu.swift
//  iOSapp
//
//  Created by Ran Reichman on 2/26/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

func handleSpamReport(alertAction: UIAlertAction)
{
    print("this is spam")
}

func handleContentNotOriginalReport(alertAction: UIAlertAction)
{
    print("content not original")
}

func handlePhotoNotOriginalReport(alertAction: UIAlertAction)
{
    print("photo not original")
}

func handleHarmfulOrOffendingReport(alertAction: UIAlertAction)
{
    print("harmful or offending")
}

func handleIdontLikeThisReport(alertAction: UIAlertAction)
{
    print("I don't like this")
}

func handleSnippetMenuButtonClicked(viewController : UIViewController)
{
    print("test button")
    let alertController = UIAlertController()
    
    let spamAction = UIAlertAction(title: "Report Spam", style: .default, handler: handleSpamReport)
    let notOriginalContentAction = UIAlertAction(title: "Content Isn't Original", style: .default, handler: handleContentNotOriginalReport)
    let notOriginalPhotoAction = UIAlertAction(title: "Photo Isn't Original", style: .default, handler: handlePhotoNotOriginalReport)
    let harmfulOrOffendingAction = UIAlertAction(title: "Post is Harmful or Offending", style: .default, handler: handleHarmfulOrOffendingReport)
    let dontLikeThisAction = UIAlertAction(title: "I Don't Like This", style: .default, handler: handleIdontLikeThisReport)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
    
    alertController.addAction(spamAction)
    alertController.addAction(notOriginalContentAction)
    alertController.addAction(notOriginalPhotoAction)
    alertController.addAction(harmfulOrOffendingAction)
    alertController.addAction(dontLikeThisAction)
    alertController.addAction(cancelAction)
    
    viewController.present(alertController, animated: true)
}
