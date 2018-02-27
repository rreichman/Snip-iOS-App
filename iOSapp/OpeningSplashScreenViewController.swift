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
    
    var feedDataSource : FeedDataSource = FeedDataSource()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("loaded splash screen: \(Date())")
        
        Logger().logStartedSplashScreen()
        UserInformation().getUserInformationFromWeb()
        loadSplashScreenImages()
        print("done loading splash screen: \(Date())")
    }
    
    func loadSplashScreenImages()
    {
        splashScreenLogoImage.image = #imageLiteral(resourceName: "snipLogo")
        splashScreenSummarizedLineImage.image = #imageLiteral(resourceName: "newsSummarized")
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
        
        SnipRetrieverFromWeb.shared.clean()
        SnipRetrieverFromWeb.shared.lock.lock()
        print("about to get snips from server \(Date())")
        SnipRetrieverFromWeb.shared.getSnipsJsonFromWebServer(completionHandler: self.collectionCompletionHandler, appendDataAndNotReplace: false)
    }
    
    func collectionCompletionHandler(postDataArray: [PostData], appendDataAndNotReplace : Bool)
    {
        print("starting here: \(Date())")
        if (!appendDataAndNotReplace)
        {
            feedDataSource.postDataArray = []
        }
        
        for postData in postDataArray
        {
            feedDataSource.postDataArray.append(postData)
        }
        
        var i = 0
        for postData in feedDataSource.postDataArray
        {
            let INITIAL_NUMBER_OF_IMAGES_COLLECTED = 2
            print("getting images: \(Date())")
            if (i < INITIAL_NUMBER_OF_IMAGES_COLLECTED)
            {
                print("getting image: \(i) \(Date())")
                let imageData = WebUtils().getImageFromWebSync(urlString: postData.image._imageURL)
                postData.image.setImageData(imageData: imageData)
            }
            print("done getting images: \(Date())")

            i += 1
        }
        
        print("performing segue: \(Date())")

        performSegue(withIdentifier: "segueToTableView", sender: self)
        SnipRetrieverFromWeb.shared.lock.unlock()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("preparing")
        if (segue.identifier == "segueToTableView")
        {
            print("preparing segue: \(Date())")
            let navigationController = segue.destination as! UINavigationController
            let tableViewController = navigationController.viewControllers.first as! SnippetsTableViewController
            tableViewController.tableView.dataSource = feedDataSource
            tableViewController.getRestOfImagesAsync()
            tableViewController.tableView.reloadData()
            print("done with prepare: \(Date())")
        }
    }
}
