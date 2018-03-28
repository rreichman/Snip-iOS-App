//
//  SplashScreenViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class OpeningSplashScreenViewController: UIViewController
{
    @IBOutlet weak var splashScreenBackgroundImage: UIImageView!
    @IBOutlet weak var splashScreenLogoImage: UIImageView!
    @IBOutlet weak var splashScreenSummarizedLineImage: UIImageView!
    
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoViewLeadingConstraint: NSLayoutConstraint!
    
    var snippetsTableViewController = SnippetsTableViewController()
    var _snipRetrieverFromWeb : SnipRetrieverFromWeb = SnipRetrieverFromWeb()
    var _postDataArray : [PostData] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("loaded splash screen: \(Date())")
        
        UserInformation().getUserInformationFromWeb()
        Logger().logStartedSplashScreen()
        loadSplashScreenImages()
        print("done loading splash screen: \(Date())")
    }
    
    func loadSplashScreenImages()
    {
        splashScreenLogoImage.image = #imageLiteral(resourceName: "snipLogo")
        splashScreenSummarizedLineImage.image = #imageLiteral(resourceName: "newsSummarized")
        splashScreenLogoImage.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        splashScreenSummarizedLineImage.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        splashScreenBackgroundImage.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        logoView.backgroundColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
        
        logoViewTopConstraint.constant = (CachedData().getScreenHeight() - logoView.bounds.height) / 2
        logoViewLeadingConstraint.constant = (CachedData().getScreenWidth() - logoView.bounds.width) / 2
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        print("before super didAppear \(Date())")
        super.viewDidAppear(animated)
        print("after super didAppear \(Date())")
        
        _snipRetrieverFromWeb.isCoreSnipViewController = true
        _snipRetrieverFromWeb.clean()
        _snipRetrieverFromWeb.lock.lock()
        print("about to get snips from server \(Date())")
        _snipRetrieverFromWeb.getSnipsJsonFromWebServer(completionHandler: self.collectionCompletionHandler, appendDataAndNotReplace: false)
    }
    
    func collectionCompletionHandler(postsToAdd: [PostData], appendDataAndNotReplace : Bool)
    {
        print("starting here: \(Date())")
        _postDataArray = WebUtils.shared.addPostsToFeed(snipRetriever: _snipRetrieverFromWeb, originalPostDataArray: _postDataArray, postsToAdd: postsToAdd, appendDataAndNotReplace: appendDataAndNotReplace)
        /*if (!appendDataAndNotReplace)
        {
            _postDataArray = []
        }
        
        for postData in postsToAdd
        {
            _postDataArray.append(postData)
        }
        
        var i = 0
        for postData in _postDataArray
        {
            let INITIAL_NUMBER_OF_IMAGES_COLLECTED = 2
            if (i < INITIAL_NUMBER_OF_IMAGES_COLLECTED)
            {
                let imageData = WebUtils().getImageFromWebSync(urlString: postData.image._imageURL)
                postData.image.setImageData(imageData: imageData)
            }

            i += 1
        }
        
        _snipRetrieverFromWeb.lock.unlock()*/
        
        print("performing segue: \(Date())")
        performSegue(withIdentifier: "segueToTableView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("preparing")
        if (segue.identifier == "segueToTableView")
        {
            print("preparing segue: \(Date())")
            let navigationController = segue.destination as! UINavigationController
            let snippetsTableViewController = navigationController.viewControllers.first as! SnippetsTableViewController
            snippetsTableViewController.snipRetrieverFromWeb = _snipRetrieverFromWeb
            snippetsTableViewController._postDataArray = _postDataArray
            print("done with prepare: \(Date())")
        }
    }
}
