//
//  HomeFeedViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

protocol MainFeedViewDelegate: class {
    func onCategorySelected(category: Category)
    func refreshFeed()
    func showDetail(for post: Post)
    func showWriterPosts(writer: User)
}

class MainFeedViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var categories: Results<Category>?
    var tokens: [NotificationToken] = []
    var delegate: MainFeedViewDelegate!
    var expandedSet = Set<IndexPath>()
    var refreshControl: UIRefreshControl = UIRefreshControl()
    override func viewDidLoad() {
        
        self.navigationItem.title = "HOME"
        //self.tableView.estimatedRowHeight = 0
        //self.tableView.estimatedSectionHeaderHeight = 0
        //self.tableView.estimatedSectionFooterHeight = 0
        //tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        //tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let nib = UINib(nibName: "NewSnippetTableViewCell", bundle: nil)
        tableView.register(SnipHeaderView.self, forHeaderFooterViewReuseIdentifier: SnipHeaderView.reuseIdent)
        tableView.register(SnipFooterView.self, forHeaderFooterViewReuseIdentifier: SnipFooterView.reuseIdent)
        tableView.register(nib, forCellReuseIdentifier: NewSnippetTableViewCell.cellReuseIdentifier)
        addRefresh()
    }
    
    func setCategoryList(categories: Results<Category>) {
        self.categories = categories
        for cat in categories {
            let t = cat.topThreePosts.observe { [weak self, cat] (changes) in
                guard let s = self else { return }
                guard let _ = s.tableView else { return }
                
                switch changes {
                case.update(_, let deletions, let insertions, let modifications):
                    guard let index = categories.index(of: cat) else { return }
                    //print("notification: \(deletions.count) deletions, \(insertions.count) insertions, \(modifications.count) modifications) ")
                    if insertions.count > 0 {
                        s.expandedSet.removeAll()
                    }
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
                        
                        s.tableView.reloadData()
                    }
                default:
                    break
                }
            }
            self.tokens.append(t)
        }
        /**
        self.notificationToken = categories.observe { [weak self] changes in
            guard let viewController = self else { return }
            guard let tableView = viewController.tableView else { return }
            switch changes {
            case .update(_, _, _, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.reloadSections(IndexSet(modifications), with: .automatic)
                tableView.endUpdates()
            default:
                break
            }
        }
         **/
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
        tokens.forEach { (token) in
            token.invalidate()
        }
    }
}


extension MainFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NewSnippetTableViewCell.cellReuseIdentifier) as? NewSnippetTableViewCell
        if cell == nil {
            cell = NewSnippetTableViewCell.init()
        }
        
        if let list = self.categories {
            let category = list[indexPath.section]
            let posts = category.topThreePosts
            let post = posts[indexPath.row]
            let large = expandedSet.contains(indexPath)
            cell!.bind(data: post, path: indexPath, expanded: large)
            cell!.delegate = self
            cell!.dataDelegate = PostStateManager.instance
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.categories {
            let category = list[section]
            return category.topThreePosts.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let list = self.categories {
            return list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedSet.contains(indexPath) {
            return 500
        } else {
            return 150
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension MainFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SnipHeaderView.reuseIdent) as? SnipHeaderView else { return nil }
        guard let list = self.categories else { return nil }
        header.setCatLabel(title: list[section].categoryName.uppercased())
        header.delegate = self
        header.category = list[section]
        return header
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: SnipFooterView.reuseIdent) as? SnipFooterView else { return nil }
        guard let list = self.categories else { return nil }
        footer.catLabel.text = list[section].categoryName
        footer.delegate = self
        footer.category = list[section]
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 18
    }
}

extension MainFeedViewController: SnipCellViewDelegate {
    func viewWriterPost(writer: User) {
        delegate.showWriterPosts(writer: writer)
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
            expandedSet.insert(path)
        } else {
            if expandedSet.contains(path) {
                expandedSet.remove(path)
            }
        }
        UIView.performWithoutAnimation {
            tableView.reloadRows(at: [ path ], with: .automatic)
        }
    }
}

extension MainFeedViewController: CategorySelectionDelegate {
    func onCategorySelected(category: Category) {
        delegate.onCategorySelected(category: category)
    }
    
    
}
