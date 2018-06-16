//
//  FeedNavigationViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/21/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Crashlytics

enum TableError: Error {
    case invalidUpdate(msg: String)
}

protocol FeedNavigationViewDelegate: class {
    func onBackPressed()
    func fetchNextPage()
    func refreshFeed()
    func showDetail(for post: Post, startComment: Bool)
    func viewWriterPosts(for writer: User)
    func openInternalLink(url: URL)
}

class PostListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var initialsLabel: UILabel!
    @IBOutlet var headerContainer: UIView!
    var delegate: FeedNavigationViewDelegate!
    var posts: List<Post>?
    var navTitle: String?
    var notificationToken: NotificationToken?
    var expandedSet = Set<Int>()
    var refreshControl: UIRefreshControl!
    
    var displayUserHeader: Bool = false
    var userName: String = ""
    var userInitials: String = ""
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        //whiteBackArrow()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        addRefresh()
        let nib = UINib(nibName: "NewSnippetTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: NewSnippetTableViewCell.cellReuseIdentifier)
        
        self.bindViews(posts: self.posts, navTitle: self.navTitle)
    }
    
    func setUserHeader(name: String, initials: String) {
        self.displayUserHeader = true
        self.userName = name
        self.userInitials = initials.uppercased()
    }
    
    
    
    func bindData(posts: List<Post>, description: String?) {
        self.posts = posts
        self.navTitle = description
        subscribeToRealmNotifications(posts: posts)
        bindViews(posts: posts, navTitle: navTitle)
    }
    
    func bindViews(posts: List<Post>?, navTitle: String?) {
        if let tv = self.tableView {
            if !self.displayUserHeader {
                tv.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            } else {
                tv .tableHeaderView = headerContainer
                // If the tableView has been constructed, the labels are there too
                authorLabel.text = self.userName
                initialsLabel.text = self.userInitials
            }
            if posts != nil {
                tv.reloadData()
            }
        }
        
        if let title = navTitle {
            self.navigationItem.title = title.uppercased()
        } else {
            self.navigationItem.title = ""
        }
        
    }
    
    func subscribeToRealmNotifications(posts: List<Post>) {
        self.notificationToken = posts.observe { [weak self] changes in
            guard let viewController = self else { return }
            guard let tableView = viewController.tableView else { return }
            viewController.endRefreshing()
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                //print("notification: \(deletions.count) deletions, \(insertions.count) insertions, \(modifications.count) modifications, array size: \(String(describing: viewController.posts?.count)) ")
                deletions.forEach({ (deletion) in
                    if viewController.expandedSet.contains(deletion) {
                        viewController.expandedSet.remove(deletion)
                    }
                })
                UIView.performWithoutAnimation {
                    // Just another thing that started so promising and ends so poorly. With animations broken and now update maps not even working, realm isnt really even adding any value anymore
                    /**
                     s.tableView.beginUpdates()
                     s.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: index) }),
                     with: .none)
                     s.tableView.reloadRows(at: insertions.map({ IndexPath(row: $0, section: index) }),
                     with: .none)
                     
                     s.tableView.endUpdates()
                     **/
                    
                    viewController.tableView.reloadData()
                }
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    @objc func backButtonTapped() {
        delegate.onBackPressed()
    }
    
    private func whiteBackArrow() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 44, height: 44)
        menuBtn.imageEdgeInsets = UIEdgeInsetsMake(14, 0, 14, 26)
        menuBtn.setImage(UIImage(named:"whiteBackArrow"), for: .normal)
        menuBtn.addTarget(self, action: #selector(backButtonTapped), for: UIControlEvents.touchUpInside)
        menuBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 44)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    func addRefresh() {
        self.refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1.0)

        self.tableView.addSubview(self.refreshControl)
    }
    
    @objc func handleRefresh() {
        delegate.refreshFeed()
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    deinit {
        if let token = self.notificationToken {
            token.invalidate()
        }
    }
}


extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NewSnippetTableViewCell.cellReuseIdentifier) as? NewSnippetTableViewCell
        if cell == nil {
            cell = NewSnippetTableViewCell.init()
        }
        
        if let list = self.posts {
            if list.count <= indexPath.row {
                // I have no examples that have this check and I've never had this problem before.
                // The only thing this is flow is doing differently is deleting all of data and setting rows to 0 before adding new data. The table is asking for a cell before checking if it even need that many rows
                return cell!
            }
            let post = list[indexPath.row]
            let large = expandedSet.contains(indexPath.row)
            cell!.bind(data: post, path: indexPath, expanded: large)
            cell!.delegate = self
            cell!.bodyTextView.delegate = self
            cell!.dataDelegate = PostStateManager.instance
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.posts {
            return list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let postList = self.posts else { return }
        if indexPath.row + 6 > postList.count {
            delegate.fetchNextPage()
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedSet.contains(indexPath.row) {
            return 500
        } else {
            return 150
        }
    }
 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
}

extension PostListViewController: SnipCellViewDelegate {
    func showExpandedImage(for post: Post) {
        ExpandedImageViewController.showExpandedImage(for: post, presentingVC: self)
    }
    
    func viewWriterPost(writer: User) {
        delegate.viewWriterPosts(for: writer)
    }
    
    func postOptions(for post: Post) {
        PostStateManager.instance.handleSnippetMenuButtonClicked(snippetID: post.id, viewController: self)
    }
    
    func showDetail(for post: Post, startComment: Bool) {
        delegate.showDetail(for: post, startComment: startComment)
    }
    
    
    func share(msg: String, url: NSURL, sourceView: UIView) {
        let objects = [msg, url] as [ Any ]
        let activityVC = UIActivityViewController(activityItems: objects, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sourceView
        present(activityVC, animated: true, completion: nil)
    }
    
    func setExpanded(large: Bool, path: IndexPath) {
        if large {
            expandedSet.insert(path.row)
        } else {
            if expandedSet.contains(path.row) {
                expandedSet.remove(path.row)
            }
        }
        UIView.performWithoutAnimation {
            tableView.reloadRows(at: [ path ], with: .automatic)
            if large {
                tableView.scrollToRow(at: path, at: .top, animated: true)
            }
        }
    }
}

extension PostListViewController: FeedView {
    func scrollToTop() {
        guard let _ = tableView else { return }
        tableView.setContentOffset(.zero, animated: true)
    }
}

extension PostListViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if AppLinkUtils.shouldOpenLinkInApp(link: URL) {
            print("Opening internal link \(URL.absoluteString)")
            delegate.openInternalLink(url: URL)
        } else {
            UIApplication.shared.open(URL, options: [:])
        }
        
        return false
    }
}
