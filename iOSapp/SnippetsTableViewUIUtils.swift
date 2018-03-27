//
//  SnippetTableViewUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/26/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

extension SnippetsTableViewController
{
    func runLoadingIndicator()
    {
        loadingIndicator.startAnimating()
        loadingIndicator.frame = CGRect(x: 0, y: 0, width: CachedData().getScreenWidth(), height: 44)
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
        goBackWithoutNavigationBar(navigationController: navigationController!, showNavigationBar: true)
    }
    
    func scrollToTopOfTable()
    {
        let top = NSIndexPath(row: NSNotFound , section: 0)
        tableView.scrollToRow(at: top as IndexPath, at: .bottom, animated: false)
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
}
