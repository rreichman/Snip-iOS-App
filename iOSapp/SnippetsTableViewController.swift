//
//  TableViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/23/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import Cache

// TODO: This should be a GenericProgramViewController
class SnippetsTableViewController: UITableViewController
{
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    var heightAtIndexPath = NSMutableDictionary()
    var finishedLoadingSnippets = false
    var rowCurrentlyClicked = 0
    
    override func viewDidLoad()
    {
        print("loading snippetViewController")
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 700
        
        tableView.separatorColor = UIColor.clear
        
        turnNavigationBarTitleIntoButton(title: "Home")
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(profileButtonPressed)
        
        refreshControl?.backgroundColor = UIColor.lightGray
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        print("done loading snippetViewController")
    }
    
    func getRestOfImagesAsync()
    {
        let storage = AppCache.shared.getStorage()
        
        for postData in (self.tableView.dataSource as! FeedDataSource).postDataArray
        {
            if !postData.image._gotImageData
            {
                if let cachedImage = try? storage.object(ofType: ImageWrapper.self, forKey: postData.image._imageURL).image
                {
                    postData.image.setImageData(imageData: cachedImage)
                }
                else
                {
                    DispatchQueue.global(qos: .background).async
                    {
                        let url = NSURL(string:postData.image._imageURL)
                        let data = NSData(contentsOf:url! as URL)
                        if data != nil
                        {
                            postData.image.setImageData(imageData: UIImage(data:data! as Data)!)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func menuButtonPressed(_ sender: UIBarButtonItem)
    {
        performSegue(withIdentifier: "showMenuSegue", sender: self)
    }
    
    @IBAction func commentsButtonPressed(_ sender: Any)
    {
        performSegue(withIdentifier: "showCommentsSegue", sender: self)
    }
    
    @objc func profileButtonPressed()
    {
        if (UserInformation().isUserLoggedIn())
        {
            performSegue(withIdentifier: "showProfileSegue", sender: self)
        }
        else
        {
            performSegue(withIdentifier: "showLoginSegue", sender: self)
        }
    }
    
    func collectionErrorHandler()
    {
        DispatchQueue.main.async
        {
            if (self.refreshControl?.isRefreshing)!
            {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc func refresh(_ sender: UIRefreshControl)
    {
        print("refresh")
        Logger().logRefreshOfTableView()
        SnipRetrieverFromWeb.shared.clean()
        SnipRetrieverFromWeb.shared.getSnipsJsonFromWebServer(completionHandler: self.dataCollectionCompletionHandler, appendDataAndNotReplace: false, errorHandler: self.collectionErrorHandler)
    }
    
    func updateTableInfoFeedDataSource(postDataArray : [PostData], appendDataAndNotReplace : Bool)
    {
        // TODO: there's some code multiplication here with opening splash screen but not sure it's worth the trouble.
        var newDataArray : [PostData] = []
        if (appendDataAndNotReplace)
        {
            newDataArray = (self.tableView.dataSource as! FeedDataSource).postDataArray
        }
        else
        {
            (self.tableView.dataSource as! FeedDataSource).cellsNotToTruncate.removeAll()
        }
        
        DispatchQueue.global(qos: .background).async
        {
            for postData in postDataArray
            {
                let imageData = WebUtils().getImageFromWebSync(urlString: postData.image._imageURL)
                postData.image.setImageData(imageData: imageData)
                
                newDataArray.append(postData)
            }
            
            DispatchQueue.main.async
            {
                (self.tableView.dataSource as! FeedDataSource).postDataArray = newDataArray
                self.tableView.reloadData()
                
                SnipRetrieverFromWeb.shared.lock.unlock()
                self.finishedLoadingSnippets = true
            }
        }
    }
    
    func dataCollectionCompletionHandler(postDataArray: [PostData], appendDataAndNotReplace : Bool)
    {
        DispatchQueue.main.async
        {
            if (self.refreshControl?.isRefreshing)!
            {
                self.refreshControl?.endRefreshing()
            }
            self.updateTableInfoFeedDataSource(postDataArray: postDataArray, appendDataAndNotReplace : appendDataAndNotReplace)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "showCommentsSegue")
        {
            let commentsViewController = segue.destination as! CommentsTableViewController
            let currentPost : PostData = (tableView.dataSource as! FeedDataSource).postDataArray[rowCurrentlyClicked]
            commentsViewController.currentSnippetID = currentPost.id
        }
        
        let nextViewController = segue.destination as! GenericProgramViewController
        nextViewController.viewControllerToReturnTo = self
    }
    
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let newCellHeightAsFloat : Float = Float(cell.frame.size.height)
        
        DispatchQueue.global(qos: .background).async{
            let height = NSNumber(value: newCellHeightAsFloat)
            let previousHeight = self.heightAtIndexPath.object(forKey: indexPath as NSCopying)
            if (previousHeight != nil)
            {
                if (newCellHeightAsFloat == previousHeight as! Float)
                {
                    return
                }
            }
            self.heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
            
            DispatchQueue.main.async {
                // TODO: This is buggy since I'm logging some snippets many times. Not too important now
                if (self.finishedLoadingSnippets)
                {
                    let foregroundSnippetIDs = self.getForegroundSnippetIDs()
                    for snippetID in foregroundSnippetIDs
                    {
                        Logger().logViewingSnippet(snippetID: snippetID)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func getForegroundSnippetIDs() -> [Int]
    {
        let dataSource : FeedDataSource = tableView.dataSource as! FeedDataSource
        let indexPathsForVisibleRows : [IndexPath] = tableView.indexPathsForVisibleRows as! [IndexPath]
        let numberOfVisibleRows = indexPathsForVisibleRows.count
        
        if numberOfVisibleRows == 2
        {
            return [dataSource.postDataArray[indexPathsForVisibleRows[0].row].id]
        }
        
        var snippetIDs : [Int] = []
        
        if numberOfVisibleRows > 2
        {
            // Getting all the middle rows
            for i in 0...numberOfVisibleRows-1
            {
                snippetIDs.append(dataSource.postDataArray[indexPathsForVisibleRows[i].row].id)
            }
        }
        else
        {
            Logger().logWeirdNumberOfSnippetsOnScreen(numberOfSnippets : numberOfVisibleRows)
        }
        
        return snippetIDs
    }
    
    // Perhaps this can be non-objc with some modifications
    @objc func homeButtonAction(sender: Any)
    {
        let top = NSIndexPath(row: NSNotFound , section: 0)
        tableView.scrollToRow(at: top as IndexPath, at: .bottom, animated: true)
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
                         action: #selector(self.homeButtonAction),
                         for: .touchUpInside)
        self.navigationItem.titleView = button
    }
}
