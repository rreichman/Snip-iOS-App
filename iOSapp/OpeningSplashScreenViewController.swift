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
    @IBOutlet weak var splashScreenImage: UIImageView!
    
    var feedDataSource : FeedDataSource = FeedDataSource()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("loaded splash screen")
        
        Logger().logStartedSplashScreen()
        UserInformation().getUserInformationFromWeb()
        splashScreenImage.image = #imageLiteral(resourceName: "splashScreenImage")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        print("appeared")
        
        SnipRetrieverFromWeb.shared.clean()
        SnipRetrieverFromWeb.shared.lock.lock()
        SnipRetrieverFromWeb.shared.getSnipsJsonFromWebServer(completionHandler: self.collectionCompletionHandler, appendDataAndNotReplace: false)
    }
    
    func collectionCompletionHandler(postDataArray: [PostData], appendDataAndNotReplace : Bool)
    {
        if (!appendDataAndNotReplace)
        {
            feedDataSource.postDataArray = []
        }
        
        for postData in postDataArray
        {
            feedDataSource.postDataArray.append(postData)
        }
        
        for postData in feedDataSource.postDataArray
        {
            let imageData = WebUtils().getImageFromWebSync(urlString: postData.image._imageURL)
            postData.image.setImageData(imageData: imageData)
        }

        performSegue(withIdentifier: "segueToTableView", sender: self)
        SnipRetrieverFromWeb.shared.lock.unlock()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("preparing")
        if (segue.identifier == "segueToTableView")
        {
            print("seguing")
            let navigationController = segue.destination as! UINavigationController
            let tableViewController = navigationController.viewControllers.first as! SnippetsTableViewController
            tableViewController.tableView.dataSource = feedDataSource
            tableViewController.tableView.reloadData()
        }
    }
}
