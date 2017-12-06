//
//  SplashScreenViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit


class SplashScreenViewController: UIViewController
{
    @IBOutlet weak var splashScreenImage: UIImageView!
    var dataSource : FeedDataSource = FeedDataSource()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Logger().logStartedSplashScreen()
        UserInformation().getUserInformationFromWeb()
        splashScreenImage.image = #imageLiteral(resourceName: "splashScreenImage")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        print("appeared")
        
        SnipRetrieverFromWeb.shared.lock.lock()
        SnipRetrieverFromWeb.shared.getSnipsJsonFromWebServer(completionHandler: self.collectionCompletionHandler)
    }
    
    func collectionCompletionHandler(feedDataSource: FeedDataSource)
    {
        dataSource = feedDataSource
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
            tableViewController.tableView.dataSource = dataSource
            tableViewController.tableView.reloadData()
        }
    }
}
