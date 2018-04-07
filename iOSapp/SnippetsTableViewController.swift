//
//  TableViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/23/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import Cache

class SnippetsTableViewController: GenericProgramViewController, UITableViewDelegate, UITableViewDataSource
{
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    var heightAtIndexPath = NSMutableDictionary()
    var finishedLoadingSnippets = false
    var rowCurrentlyClicked = 0
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    // TODO: perhaps there's a better way
    var shouldEnterCommentOfFirstSnippet = false
    var shouldHaveBackButton = false
    var shouldShowNavigationBar = true
    var shouldShowProfileView = true
    var shouldShowBackView = false
    
    var pageTitle = "Home"
    var pageWriterIfExists = "Page Writer"
    
    var _postDataArray: [PostData] = []
    var cellsNotToTruncate : Set<Int> = Set<Int>()
    
    var snipRetrieverFromWeb : SnipRetrieverFromWeb = SnipRetrieverFromWeb()
    var titleHeadlineString : NSAttributedString = NSAttributedString()
    
    let loadingIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var backHeaderView: BackHeaderView!
    @IBOutlet weak var backHeaderViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var profileViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        print("loading snippetViewController: \(Date())")
        super.viewDidLoad()
     
        runLoadingIndicator()
     
        tableView.dataSource = self
        tableView.delegate = self
     
        if (snipRetrieverFromWeb.isCoreSnipViewController || !shouldShowProfileView)
        {
            profileViewHeightConstraint.constant = 0
        }
        if (!shouldShowBackView)
        {
            backHeaderView.isHidden = true
            backHeaderViewHeightConstraint.constant = 0
        }
        else
        {
            backHeaderView.titleLabel.attributedText = titleHeadlineString
        }
        
        getRestOfImagesAsync()
        
        tableView.tableFooterView = loadingIndicator
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.clear
        
        handleNavigationBar()
        
        profileView.setUI(receivedUserFullName: pageWriterIfExists)
        profileView.currentViewController = self
        backHeaderView.currentViewController = self
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.backgroundColor = UIColor.lightGray
        tableView.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        
        scrollToTopOfTable()
        
        print("done loading snippetViewController: \(Date())")
    }
    
    @IBAction func menuButtonPressed(_ sender: Any)
    {
        performSegue(withIdentifier: "showMenuSegue", sender: self)
    }
    
    func commentsButtonPressed(_ sender: Any)
    {
        performSegue(withIdentifier: "showCommentsSegue", sender: self)
    }
    
    @IBAction func profileButtonPressed(_ sender: Any)
    {
        if (UserInformation().isUserLoggedIn())
        {
            performSegue(withIdentifier: "showProfileSegue", sender: self)
        }
        else
        {
            performSegue(withIdentifier: "showLoginWelcomeSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "showCommentsSegue")
        {
            let commentsViewController = segue.destination as! CommentsTableViewController
            let currentPost : PostData = _postDataArray[rowCurrentlyClicked]
            commentsViewController.currentSnippetID = currentPost.id
        }
        
        let nextViewController = segue.destination as! GenericProgramViewController
        nextViewController.viewControllerToReturnTo = self
    }
    
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        // TODO: This is buggy since I'm logging some snippets many times. Not too important now
        if (self.finishedLoadingSnippets)
        {
            let foregroundSnippetIDs = self.getForegroundSnippetIDs()
            for snippetID in foregroundSnippetIDs
            {
                DispatchQueue.global(qos: .background).async
                {
                    Logger().logViewingSnippet(snippetID: snippetID)
                }
            }
        }
        
        let newCellHeightAsFloat : Float = Float(cell.frame.size.height)
        
        let height = NSNumber(value: Float(cell.frame.size.height))
        let previousHeight = self.heightAtIndexPath.object(forKey: indexPath as NSCopying)
        if (previousHeight != nil)
        {
            if (newCellHeightAsFloat == previousHeight as! Float)
            {
                return
            }
        }
        
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return _postDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        handleInfiniteScroll(tableView : tableView, currentRow: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SnippetTableViewCell
        let postData = _postDataArray[indexPath.row]
        
        cell.m_isTextLongEnoughToBeTruncated = self._postDataArray[indexPath.row].m_isTextLongEnoughToBeTruncated
        let shouldTruncate : Bool = !self.cellsNotToTruncate.contains(indexPath.row)
        
        cell.snippetView.userImage.loadInitialsIntoUserImage(writerName: postData.writerString, sizeOfView: 30, sizeOfFont: 13)
        
        loadDataIntoSnippet(snippetView: cell.snippetView, shouldTruncate: shouldTruncate, postData: postData)
        cell.snippetView.currentViewController = self
        
        return cell
    }
}
