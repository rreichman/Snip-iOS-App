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

class HomeFeedViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var categories: Results<Category>?
    var notificationToken: NotificationToken?
    var expandedSet = Set<IndexPath>()
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
    }
    
    func setCategoryList(categories: Results<Category>) {
        self.categories = categories
        
        self.notificationToken = categories.observe { [weak self] changes in
            guard let viewController = self else { return }
            guard let tableView = viewController.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .none)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    deinit {
        if let tok = self.notificationToken {
            tok.invalidate()
        }
    }
}


extension HomeFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NewSnippetTableViewCell.cellReuseIdentifier) as? NewSnippetTableViewCell
        if cell == nil {
            cell = NewSnippetTableViewCell.init()
        }
        
        if let list = self.categories {
            let category = list[indexPath.section]
            let posts = category.posts
            let post = posts[indexPath.row]
            let large = expandedSet.contains(indexPath)
            cell!.bind(data: post, path: indexPath, expanded: large)
            cell!.delegate = self
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.categories {
            let category = list[section]
            return category.posts.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let list = self.categories {
            return list.count
        }
        return 0
    }
    /**
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedSet.contains(indexPath) {
            return 500
        } else {
            return 150
        }
    }
     **/
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
     */
}

extension HomeFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SnipHeaderView.reuseIdent) as? SnipHeaderView else { return nil }
        guard let list = self.categories else { return nil }
        header.catLabel.text = list[section].categoryName.uppercased()
        return header
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: SnipFooterView.reuseIdent) as? SnipFooterView else { return nil }
        guard let list = self.categories else { return nil }
        footer.catLabel.text = list[section].categoryName
        return footer
    }
    /**
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    **/
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 18
    }
}

extension HomeFeedViewController: SnipTableViewDelegate {
    func setExpanded(large: Bool, path: IndexPath) {
        if large {
            expandedSet.insert(path)
        } else {
            if expandedSet.contains(path) {
                expandedSet.remove(path)
            }
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: [ path ], with: .automatic)
        tableView.endUpdates()
    }
}
