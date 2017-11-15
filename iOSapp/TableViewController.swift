//
//  TableViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/23/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import Cache

class TableViewController: UITableViewController
{
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    var heightAtIndexPath = NSMutableDictionary()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        
        turnNavigationBarTitleIntoButton(title: "Home")
        
        // Perhaps need more advanced logic here
        if (tableView.dataSource is FeedDataSource)
        {
            print("not collecting anymore")
            let dataSource : FeedDataSource = tableView.dataSource as! FeedDataSource
            if (dataSource.postDataArray.count > 0)
            {
                return
            }
        }
        
        print("collecting more")
        SnipRetrieverFromWeb.shared.getSnipsJsonFromWebServer(completionHandler: self.dataCollectionCompletionHandler)
    }
    
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func dataCollectionCompletionHandler(feedDataSource: FeedDataSource)
    {
        DispatchQueue.main.async
        {
            self.tableView.dataSource = feedDataSource
            self.tableView.reloadData()
        }
    }
    
    // Perhaps this can be non-objc with some modifications
    @objc func buttonAction(sender: Any)
    {
        // This is a nice additional margin so that the cell isn't too crowded with the top of the page. Probably there's a better way to do this but not too important.
        let additionalMarginAtBottomOfNavigationBar = CGFloat(20)
        // Bring the content to the top of the screen in a nice animated way.
        let heightOfTopOfPage = -self.navigationController!.navigationBar.frame.size.height - additionalMarginAtBottomOfNavigationBar
        tableView.setContentOffset(CGPoint(x : 0, y : heightOfTopOfPage), animated: true)
    }
    
    private func turnNavigationBarTitleIntoButton(title: String)
    {
        let button =  UIButton(type: .custom)
        let buttonHeight = self.navigationController!.navigationBar.frame.size.height
        // 0.8 is arbitrary ratio of bar to be clickable
        let buttonWidth = self.navigationController!.navigationBar.frame.size.width * 0.8
        button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = SystemVariables().NAVIGATION_BAR_TITLE_FONT
        button.addTarget(self,
                         action: #selector(self.buttonAction),
                         for: .touchUpInside)
        self.navigationItem.titleView = button
    }
}
