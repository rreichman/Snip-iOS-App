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

protocol FeedNavigationViewDelegate: class {
    func onBackPressed()
    func fetchNextPage()
    func refreshFeed()
    func showDetail(for post: Post)
    func viewWriterPosts(for writer: User)
}

class PostListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var initialsLabel: UILabel!
    @IBOutlet var headerContainer: UIView!
    var delegate: FeedNavigationViewDelegate!
    var posts: List<Post>?
    var navDescription: String?
    var notificationToken: NotificationToken?
    var expandedSet = Set<Int>()
    var refreshControl: UIRefreshControl!
    
    var displayUserHeader: Bool = false
    var userName: String = ""
    var userInitials: String = ""
    
    override func viewDidLoad() {
        
        if let d = self.navDescription {
            setNavTitle(title: d)
        }
        //self.tableView.estimatedRowHeight = 0
        //self.tableView.estimatedSectionHeaderHeight = 0
        //self.tableView.estimatedSectionFooterHeight = 0
        //tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.tableHeaderView?.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        //tableView.tableFooterView?.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        whiteBackArrow()
        if !self.displayUserHeader {
            tableView.tableHeaderView = UIView(frame: CGRect.zero)
        } else {
            tableView .tableHeaderView = headerContainer
            authorLabel.text = self.userName
            initialsLabel.text = self.userInitials
        }
        addRefresh()
        let nib = UINib(nibName: "NewSnippetTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: NewSnippetTableViewCell.cellReuseIdentifier)
    }
    func setUserHeader(name: String, initials: String) {
        self.displayUserHeader = true
        self.userName = name
        self.userInitials = initials
    }
    func setPostQuery(posts: List<Post>, description: String) {
        self.posts = posts
        navDescription = description
        setNavTitle(title: description)
        self.notificationToken = posts.observe { [weak self] changes in
            guard let viewController = self else { return }
            guard let tableView = viewController.tableView else { return }
            viewController.endRefreshing()
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                print("notification: \(deletions.count) deletions, \(insertions.count) insertions, \(modifications.count) modifications) ")
                deletions.forEach({ (deletion) in
                    if viewController.expandedSet.contains(deletion) {
                        viewController.expandedSet.remove(deletion)
                    }
                })
                UIView.performWithoutAnimation {
                    tableView.beginUpdates()
                
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .none)
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                         with: .none)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                         with: .none)
                    tableView.endUpdates()
                }
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    func setNavTitle(title: String) {
        self.navigationItem.title = title.uppercased()
    }
    
    @objc func backButtonTapped() {
        delegate.onBackPressed()
    }
    
    private func whiteBackArrow() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 18, height: 18)
        menuBtn.setImage(UIImage(named:"whiteBackArrow"), for: .normal)
        menuBtn.addTarget(self, action: #selector(backButtonTapped), for: UIControlEvents.touchUpInside)
        menuBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 18)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 18)
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
    func viewWriterPost(writer: User) {
        delegate.viewWriterPosts(for: writer)
    }
    
    func postOptions(for post: Post) {
        PostStateManager.instance.handleSnippetMenuButtonClicked(snippetID: post.id, viewController: self)
    }
    
    func showDetail(for post: Post) {
        delegate.showDetail(for: post)
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
        }
    }
}
