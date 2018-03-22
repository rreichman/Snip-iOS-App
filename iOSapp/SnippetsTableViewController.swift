//
//  TableViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/23/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import Cache

// TODO:: divide this to several classes
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
    var pageTitle = "Home"
    
    var _postDataArray: [PostData] = []
    var cellsNotToTruncate : Set<Int> = Set<Int>()
    
    var snipRetrieverFromWeb : SnipRetrieverFromWeb = SnipRetrieverFromWeb()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        print("loading snippetViewController: \(Date())")
        super.viewDidLoad()
     
        let loadingIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingIndicator.startAnimating()
        loadingIndicator.frame = CGRect(x: 0, y: 0, width: CachedData().getScreenWidth(), height: 44)
     
        tableView.dataSource = self
        tableView.delegate = self
     
        getRestOfImagesAsync()
        
        tableView.tableFooterView = loadingIndicator
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.clear
        
        handleNavigationBar()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.backgroundColor = UIColor.lightGray
        tableView.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
     
        scrollToTopOfTable()
        
        print("done loading snippetViewController: \(Date())")
    }
    
    func handleNavigationBar()
    {
        turnNavigationBarTitleIntoButton(title: pageTitle)
        
        if (shouldHaveBackButton)
        {
            let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.goBack))
            backButton.tintColor = UIColor.black
            navigationItem.leftBarButtonItem = backButton
            navigationItem.rightBarButtonItem?.image = nil
        }
        else
        {
            navigationItem.rightBarButtonItem?.target = self
            navigationItem.rightBarButtonItem?.action = #selector(profileButtonPressed)
        }
        
        navigationController?.navigationBar.barTintColor = SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR
    }
    
    @objc func goBack()
    {
        navigationController?.popViewController(animated: true)
    }
    
    func getRestOfImagesAsync()
    {
        let storage = AppCache.shared.getStorage()
        
        for postData in _postDataArray
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
            performSegue(withIdentifier: "showLoginSegue", sender: self)
        }
    }
    
    func collectionErrorHandler()
    {
        DispatchQueue.main.async
        {
            if (self.tableView.refreshControl?.isRefreshing)!
            {
                self.tableView.refreshControl?.endRefreshing()
            }
            
            if (self.activityIndicator.isAnimating)
            {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func operateRefresh(newUrlString: String, useActivityIndicator: Bool)
    {
        print("refresh")
        
        if (useActivityIndicator)
        {
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        }
        Logger().logRefreshOfTableView()
        snipRetrieverFromWeb.clean(newUrlString: newUrlString)
        fillSnippetViewController()
        scrollToTopOfTable()
    }
    
    func fillSnippetViewController()
    {
        snipRetrieverFromWeb.getSnipsJsonFromWebServer(completionHandler: self.dataCollectionCompletionHandler, appendDataAndNotReplace: false, errorHandler: self.collectionErrorHandler)
    }
    
    func scrollToTopOfTable()
    {
        let top = NSIndexPath(row: NSNotFound , section: 0)
        tableView.scrollToRow(at: top as IndexPath, at: .bottom, animated: false)
    }
    
    @objc func refresh(_ sender: UIRefreshControl)
    {
        operateRefresh(newUrlString: "", useActivityIndicator: false)
    }
    
    func updateTableInfoFeedDataSource(postsToAdd : [PostData], appendDataAndNotReplace : Bool)
    {
        // TODO: there's some code duplication here with opening splash screen but not sure it's worth the trouble.
        var newDataArray : [PostData] = []
        if (appendDataAndNotReplace)
        {
            newDataArray = _postDataArray
        }
        else
        {
            cellsNotToTruncate.removeAll()
        }
        
        DispatchQueue.global(qos: .background).async
        {
            print("started collecting all the images")
            for postData in postsToAdd
            {
                let imageData = WebUtils().getImageFromWebSync(urlString: postData.image._imageURL)
                postData.image.setImageData(imageData: imageData)
                
                newDataArray.append(postData)
            }
            print("done collecting all the images")
            
            DispatchQueue.main.async
            {
                print("starting to load data to feed")
                UIView.performWithoutAnimation
                {
                    self._postDataArray = newDataArray
                    self.tableView.reloadData()
                }
                
                self.snipRetrieverFromWeb.lock.unlock()
                self.finishedLoadingSnippets = true
                print("done loading data async")
            }
        }
    }
    
    func dataCollectionCompletionHandler(postDataArray: [PostData], appendDataAndNotReplace : Bool)
    {
        DispatchQueue.main.async
        {
            if (self.tableView.refreshControl != nil)
            {
                if (self.tableView.refreshControl?.isRefreshing)!
                {
                    self.tableView.refreshControl?.endRefreshing()
                }
            }

            self.updateTableInfoFeedDataSource(postsToAdd: postDataArray, appendDataAndNotReplace : appendDataAndNotReplace)
            
            if (self.activityIndicator.isAnimating)
            {
                self.activityIndicator.stopAnimating()
            }
            
            if (self.shouldEnterCommentOfFirstSnippet)
            {
                let firstCell : SnippetTableViewCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SnippetTableViewCell
                firstCell.snippetView.operateHandleClickOnComment(tableView: self.tableView, rowCurrentlyClicked: 0)
                print("entered first comment")
                self.shouldEnterCommentOfFirstSnippet = false
            }
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
    
    func updatePostDataAfterClick(snippetID : Int, upvoteButton: UIImageViewWithMetadata, downvoteButton: UIImageViewWithMetadata)
    {
        for postData in _postDataArray
        {
            if (postData.id == snippetID)
            {
                postData.isLiked = upvoteButton.isClicked
                postData.isDisliked = downvoteButton.isClicked
            }
        }
    }
    
    func getForegroundSnippetIDs() -> [Int]
    {
        let indexPathsForVisibleRows : [IndexPath] = tableView.indexPathsForVisibleRows!
        let numberOfVisibleRows = indexPathsForVisibleRows.count
        
        if numberOfVisibleRows == 2
        {
            return [_postDataArray[indexPathsForVisibleRows[0].row].id]
        }
        
        var snippetIDs : [Int] = []
        
        if numberOfVisibleRows > 2
        {
            // Getting all the middle rows
            for i in 0...numberOfVisibleRows-1
            {
                snippetIDs.append(_postDataArray[indexPathsForVisibleRows[i].row].id)
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
        
        loadInitialsIntoUserImage(writerName: postData.writerString, userImage: cell.snippetView.userImage)
        
        loadDataIntoSnippet(snippetView: cell.snippetView, shouldTruncate: shouldTruncate, postData: postData)
        cell.snippetView.currentViewController = self
        
        return cell
    }
    
    func loadDataIntoSnippet(snippetView: SnippetView, shouldTruncate: Bool, postData: PostData)
    {
        snippetView.setUpvoteDownvoteImagesAccordingtoVote(snippetView: snippetView, postData : postData)
        
        snippetView.writerPostTime.attributedText = postData.timeString
        snippetView.writerName.attributedText = postData.writerString
        
        // TODO: this needs to update when user deletes a comment, make it a generic function.
        snippetView.numberOfCommentsLabel.attributedText = postData.attributedStringOfCommentCount
        
        loadImageData(snippetView: snippetView, postData: postData)
        
        fillImageDescription(snippetView: snippetView, imageDescription: postData.imageDescriptionAfterHtmlRendering)
        
        snippetView.makeSnippetClickable(snippetView: snippetView)
        snippetView.isTextLongEnoughToBeTruncated = postData.m_isTextLongEnoughToBeTruncated
        
        snippetView.truncatedBody = postData.textAsAttributedStringWithTruncation
        snippetView.nonTruncatedBody = postData.textAsAttributedStringWithoutTruncation
        
        setSnippetText(snippetView: snippetView, postData : postData, shouldTruncate: shouldTruncate)
        
        setSnippetReferences(snippetView : snippetView, postData: postData, shouldTruncate: shouldTruncate, isTextLongEnoughToBeTruncated:
            postData.m_isTextLongEnoughToBeTruncated)
        
        setSnippetHeadline(snippetView: snippetView, postData : postData)
        
        snippetView.fullURL = postData.fullURL
        snippetView.currentSnippetId = postData.id
        
        snippetView.setNeedsLayout()
        snippetView.layoutIfNeeded()
    }
    
    func handleInfiniteScroll(tableView : UITableView, currentRow : Int)
    {
        let SPARE_ROWS_UNTIL_MORE_SCROLL = 5
        if _postDataArray.count - currentRow < SPARE_ROWS_UNTIL_MORE_SCROLL
        {
            print("getting more posts. Current URL string: \(snipRetrieverFromWeb.currentUrlString)")
            Logger().logScrolledToInfiniteScroll()
            let tableViewController : SnippetsTableViewController = tableView.delegate as! SnippetsTableViewController
            snipRetrieverFromWeb.loadMorePosts(completionHandler: tableViewController.dataCollectionCompletionHandler)
        }
    }
    
    func loadImageData(snippetView: SnippetView, postData: PostData)
    {
        snippetView.postImage.image = nil
        if (postData.image._gotImageData)
        {
            snippetView.postImageHeightConstraint.constant = postData.image._imageHeight
            snippetView.postImage.image = postData.image.getImageData()
        }
    }
    
    func loadSnippetFromID(snippetView : SnippetView, snippetID: Int, shouldTruncate: Bool)
    {
        for i in 0..._postDataArray.count-1
        {
            if (_postDataArray[i].id == snippetID)
            {
                let postData = _postDataArray[i]
                loadDataIntoSnippet(snippetView: snippetView, shouldTruncate: shouldTruncate, postData: postData)
            }
        }
    }
    
    func getSnippetComments(snippetID : Int) -> [Comment]
    {
        for i in 0..._postDataArray.count-1
        {
            if (_postDataArray[i].id == snippetID)
            {
                return _postDataArray[i].comments
            }
        }
        
        return []
    }
    
    func setSnippetComments(snippetID : Int, newComments : [Comment])
    {
        for i in 0..._postDataArray.count-1
        {
            if (_postDataArray[i].id == snippetID)
            {
                let newPostData = _postDataArray[i]
                newPostData.comments = newComments
                _postDataArray[i] = newPostData
            }
        }
    }
}
