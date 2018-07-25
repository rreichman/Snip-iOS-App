//
//  FeedCollectionViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/19/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import IGListKit
import RealmSwift

enum FeedViewType {
    case main(categories: Results<Category>)
    case list(posts: List<Post>, navTitle: String, writer: User?)
}

protocol PostInteractionDelegate: class {
    func setExpanded(postId: Int, _ expanded: Bool)
    func showCategoryPosts(categoryName: String)
    func showPostDetail(postId: Int, startComment: Bool)
    func showWritersPosts(writerUserName: String)
    func savePost(postId: Int)
    func setVoteValue(postId: Int, value: Double)
    func sharePost(postTitle: String, postUrlString: String, sourceView: UIView)
    func showPostOptions(postId: Int)
    func showExpandedImage(postId: Int)
}

protocol FeedViewDelegate: class {
    func showCategoryPosts(categoryName: String)
    func refreshFeed()
    func showDetail(postId: Int, startComment: Bool)
    func showWriterPosts(writerUsername: String)
    func viewDidAppearForTheFirstTime()
    func openInternalLink(url: URL)
    func showExpandedImageView(for post: Post)
    func fetchNextPage()
}

class FeedCollectionViewController: UIViewController, ListAdapterDataSource, UIScrollViewDelegate {
    var collectionView: UICollectionView!
    var adapter: ListAdapter?
    var postList: List<Post>?
    var refreshControl: UIRefreshControl?
    var categoryList: Results<Category>?
    var expandedSet = Set<Int>()
    var notificationToken: NotificationToken?
    var writer: User?
    weak var delegate: FeedViewDelegate?
    
    var showNotificationRequest: Bool = false
    
    private var feedViewType: FeedViewType = .list(posts: List<Post>(), navTitle: "", writer: nil)
    
    var data: [ListDiffable] = []
    let spinToken = "spinner"
    let paddingToken = "padding"
    var loading = false
    var _endOfFeed = false
    
    func mapRealmObjectsToViewModel() -> [ListDiffable] {
        var result: [ListDiffable] = []
        
        switch self.feedViewType {
        case .main:
            guard let categories = self.categoryList else { return [] }
            for c in categories {
                result.append(SectionHeaderViewModel(categoryName: c.categoryName))
                for p in c.topThreePosts {
                    result.append(p.asViewModel(expanded: self.expandedSet.contains(p.id)))
                }
                result.append(SectionFooterViewModel(categoryName: c.categoryName))
            }
        case .list:
            guard let list = self.postList else { return [] }
            for p in list {
                result.append(p.asViewModel(expanded: self.expandedSet.contains(p.id)))
            }
        }
        return result
    }
    
    func performUpdates() {
        assert(Thread.isMainThread)
        if let a = self.adapter {
            a.performUpdates(animated: false) { (success) in
                print("BATCH: COMPLETITION realm_set:\(self.postList?.count ?? 0) diff_set:\(self.data.count) success: \(success)")
            }
        }
    }
    
 
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var result: [ListDiffable] = []
        switch self.feedViewType {
        case .main:
            if showNotificationRequest {
                result.append(NotificationPromptViewModel())
            }
            result.append(paddingToken + "header" as ListDiffable)
        case .list(_, _, let writer):
            let ident = (writer == nil ? "header" : "header-blue")
            result.append(paddingToken + ident as ListDiffable)
        }
        if let writer = self.writer {
            result.append(WriterHeaderViewModel(writerName: writer.fullName(), writerUsername: writer.username, avatarUrl: writer.avatarUrl, initials: writer.initials))
        }
        
        result.append(contentsOf: mapRealmObjectsToViewModel())
        
        if loading {
            result.append(spinToken as ListDiffable)
        } else {
            result.append(paddingToken + "footer" as ListDiffable)
        }
        self.data = result
        return result
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is String:
            guard let string = object as? String else { fatalError() }
            if string == spinToken {
                return spinnerSectionController()
            } else if string.starts(with: self.paddingToken) {
                switch self.feedViewType {
                case .main:
                    return paddingSectionController(height: 20, backgroundColor: UIColor(white: 0.97, alpha: 1.0))
                case .list:
                    if string.contains("header") {
                        if string.contains("blue") {
                            return paddingSectionController(height: 20, backgroundColor: UIColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1.0))
                        } else {
                            return paddingSectionController(height: 20, backgroundColor: UIColor(white: 0.97, alpha: 1.0))
                        }
                    } else if string.contains("footer") {
                        return paddingSectionController(height: 20, backgroundColor: UIColor(white: 0.97, alpha: 1.0))
                    } else {
                        fatalError()
                    }
                }
                
            } else {
                fatalError()
            }
        case is PostViewModel:
            let p = PostSectionController()
            p.delegate = self
            return p
        case is SectionHeaderViewModel:
            let c = SectionHeaderController()
            c.delegate = self
            return c
        case is SectionFooterViewModel:
            let c = SectionHeaderController()
            c.delegate = self
            return c
        case is NotificationPromptViewModel:
            let c = NotificationPromptController()
            c.delegate = self
            return c
        case is WriterHeaderViewModel:
            let c = WriterHeaderSectionController()
            return c
        default:
            fatalError()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    func bindData(feedType: FeedViewType) {
        
        switch feedType {
        case .main(let results):
            if results.count > 0 {
                loading = false
            }
            self.categoryList = results
            self.navigationItem.title = "HOME"
        case .list(let postList, let navTitle, let writerOptional):
            if postList.count > 0 {
                self.loading = false
            }
            self.postList = postList
            self.navigationItem.title = navTitle.uppercased()
            self.writer = writerOptional
            if let w = writerOptional, let view = self.collectionView {
                view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
        
        startNotification()
        self.feedViewType = feedType
        self.showNotificationRequest = NotificationManager.instance.shouldShowNotificationRequest()
        performUpdates()
        
    }
    
    override func viewDidLoad() {
        let layout = UICollectionViewFlowLayout()
        //layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        let updater = ListAdapterUpdater()
        let adapter = ListAdapter(updater: updater, viewController: self)
        self.view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        
        self.collectionView = collectionView
        /**
        if self.writer != nil {
           self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        } else {
            self.collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        } **/
        
        self.adapter = adapter
        collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.view.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        self.refreshControl = refreshControl
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.isBeingPresented || self.isMovingToParentViewController) {
            if let d = self.delegate {
                d.viewDidAppearForTheFirstTime()
            }
        }
        startNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        endNotfication()
    }
    
    private func startNotification() {
        print("starting notifications")
        if self.notificationToken != nil {
            // Already subscribed to updates
            return
        }
        
        switch self.feedViewType {
        case .list:
            guard let postList = self.postList else { return }
            self.notificationToken = postList.observe({ [unowned self] (changes) in
                assert(Thread.isMainThread)
                print("BATCH: BEFORE_PERFORM_UPDATE realm_set:\(self.postList?.count ?? 0) diff_set:\(self.data.count)")
                switch changes {
                case .initial(let type):
                    print("BATCH: Initial notification, \(type)")
                case .update(let type, let deletions, let insertions, let modifications):
                    print("BATCH: UPDATE notification del:\(deletions.count), insert:\(insertions.count)")
                case .error(let err):
                    print("BATCH: Notification error \(err)")
                    fatalError()
                }
                self.refreshControl?.endRefreshing()
                self.loading = false
                self.performUpdates()
            })
        case .main:
            guard let results = self.categoryList else { return }
            self.notificationToken = results.observe({ [unowned self](changes) in
                assert(Thread.isMainThread)
                self.refreshControl?.endRefreshing()
                self.loading = false
                self.performUpdates()
            })
        }
    }
    
    private func endNotfication() {
        print("ending notifications")
        if let token = self.notificationToken {
            token.invalidate()
            self.notificationToken = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func endRefreshing() {
        self.refreshControl?.endRefreshing()
        self.loading = false
        self.performUpdates()
    }
    
    func resetExpandedSet() {
        self.expandedSet.removeAll()
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        switch self.feedViewType {
        case .list:
            if !_endOfFeed && !loading && distance < 500 {
                loading = true
                performUpdates()
                if let d = self.delegate {
                    d.fetchNextPage()
                } else {
                    loading = false
                }
            }
        default:
            break
        }
    }

    func endOfFeed() {
        self._endOfFeed = true
        self.loading = false
        performUpdates()
    }
    
    @objc func pullToRefresh() {
        if let d = self.delegate {
            d.refreshFeed()
        }
    }
    
    deinit {
        if let t = self.notificationToken {
            t.invalidate()
        }
    }
}

extension FeedCollectionViewController: NotificationPromptDelegate {
    func onNotificationsRequested() {
        NotificationManager.instance.showNotificationAccessRequest()
        self.showNotificationRequest = false
        performUpdates()
    }
    
    func onNotificationsDismissed() {
        self.showNotificationRequest = false
        NotificationManager.instance.userClosedNotificationBanner()
        performUpdates()
    }
    
    
}

extension FeedCollectionViewController: PostInteractionDelegate {
    func showExpandedImage(postId: Int) {
        let realm = RealmManager.instance.getMemRealm()
        guard let post = realm.object(ofType: Post.self, forPrimaryKey: postId) else { return }
        ExpandedImageViewController.showExpandedImage(for: post, presentingVC: self)
    }
    
    func showPostOptions(postId: Int) {
        PostStateManager.instance.handleSnippetMenuButtonClicked(snippetID: postId, viewController: self)
    }
    
    func sharePost(postTitle: String, postUrlString: String, sourceView: UIView) {
        PostInteractionUtils.showPostShareActionSheet(postTitle: postTitle, urlString: postUrlString, sourceView: sourceView, presentingViewController: self)
    }
    
    func savePost(postId: Int) {
        let realm = RealmManager.instance.getMemRealm()
        guard let post = realm.object(ofType: Post.self, forPrimaryKey: postId) else { return }
        
        PostStateManager.instance.onSaveAciton(saved: !post.saved, for: post)
    }
    
    func setVoteValue(postId: Int, value: Double) {
        let realm = RealmManager.instance.getMemRealm()
        guard let post = realm.object(ofType: Post.self, forPrimaryKey: postId) else { return }
        PostStateManager.instance.onVoteAciton(newVoteValue: value, for: post)
    }
    
    func showCategoryPosts(categoryName: String) {
        if let d = self.delegate {
            d.showCategoryPosts(categoryName: categoryName)
        }
    }
    
    func showPostDetail(postId: Int, startComment: Bool) {
        if let d = self.delegate {
            d.showDetail(postId: postId, startComment: startComment)
        }
    }
    
    func showWritersPosts(writerUserName: String) {
        if let d = self.delegate {
            d.showWriterPosts(writerUsername: writerUserName)
        }
    }
    
    func setExpanded(postId: Int, _ expanded: Bool) {
        if expanded {
            self.expandedSet.insert(postId)
            let postOptional = data.first { (viewModel) -> Bool in
                guard let model = viewModel as? PostViewModel else { return false }
                return model.id == postId
            } as? PostViewModel
            if let post = postOptional {
                self.adapter?.scroll(to: post, supplementaryKinds: nil, scrollDirection: .vertical, scrollPosition: .top, animated: true)
            }
            
        } else {
            self.expandedSet.remove(postId)
        }
        if let a = self.adapter {
            a.performUpdates(animated: false, completion: nil)
        }
        //performUpdates()
    }
}
