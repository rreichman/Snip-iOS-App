//
//  PostSectionController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/19/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class PostSectionController : ListBindingSectionController<PostViewModel>, ListBindingSectionControllerDataSource {
    var model: PostViewModel?
    
    let textInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    weak var delegate: PostInteractionDelegate?
    
    init(delegate: PostInteractionDelegate) {
        self.delegate = delegate
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? PostViewModel else { fatalError() }
        self.model = object
        
        var results: [ListDiffable] = [
            PostHeaderViewModel(id: object.id, title: object.title, subheadline: object.subhead, authorName: object.authorName, dateString: object.dateString, saved: object.saved, imageUrl: object.imageUrl, expanded: object.expanded, authorUsername: object.authorUsername, postUrl: object.urlString)]
        if object.expanded {
            results.append(PostContentViewModel(id: object.id, body: object.body, numberOfComments: object.numberOfComments, postUrl: object.urlString, voteValue: object.voteValue, expanded: object.expanded, authorUsername: object.authorUsername, title: object.title))
        }
        return results
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        var cellOptional: UICollectionViewCell?
        switch viewModel {
        case is PostHeaderViewModel:
            cellOptional = collectionContext?.dequeueReusableCell(withNibName: "PostHeaderCollectionCell", bundle: nil, for: self, at: index) as? UICollectionViewCell & ListBindable
            guard let _c = cellOptional as? PostHeaderCollectionCell else { fatalError() }
            _c.delegate = self.delegate
        case is PostContentViewModel:
            cellOptional = collectionContext?.dequeueReusableCell(withNibName: "PostContentCollectionCell", bundle: nil, for: self, at: index) as? UICollectionViewCell & ListBindable
            guard let _c = cellOptional as? PostContentCollectionCell else { fatalError() }
            _c.delegate = self.delegate
        default:
            cellOptional = collectionContext?.dequeueReusableCell(withNibName: "PostHeaderCollectionCell", bundle: nil, for: self, at: index) as? UICollectionViewCell & ListBindable
            guard let _c = cellOptional as? PostHeaderCollectionCell else { fatalError() }
            _c.delegate = self.delegate
        }
        guard let cell = cellOptional as? UICollectionViewCell & ListBindable else {
            fatalError()
        }
        return cell
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { fatalError() }
        
        switch viewModel {
        case is PostHeaderViewModel:
            guard let viewModel = viewModel as? PostHeaderViewModel else { fatalError() }
            /**
             Heading Cell
             Top Padding - 20
             Image height - 100
             Padding - 5
             Subheadline height - Variable
             Bottom padding - 0
            **/
            let height = TextSize.sizeAttributed(viewModel.subheadline, font: UIFont.lato(size: 15.0), width: width, insets: textInsets).height
            return CGSize(width: width, height: height + 125)
        case is PostContentViewModel:
            guard let viewModel = viewModel as? PostContentViewModel else { fatalError() }
            /**
             Content Cell
             Top Padding 0
             Body - Variable
             Padding - 10
             Vote View 44
             Padding 10
             Comment Input 64
             Padding 10
            **/
            let height = TextSize.sizeAttributed(viewModel.body, font: UIFont.lato(size: 15.0), width: width, insets: textInsets).height
            return CGSize(width: width, height: height + 138)
        default:
            return CGSize(width: width, height: 200)
        }
    }
    
    override func numberOfItems() -> Int {
        if let model = self.model {
            return (model.expanded ? 2 : 1)
        } else {
            print("!! Post Section Controller requested number of items before we set a model")
            return 1
        }
    }
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        dataSource = self
        transitionDelegate = self
        workingRangeDelegate = self
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
    }
}

extension PostSectionController: IGListTransitionDelegate {
    func listAdapter(_ listAdapter: ListAdapter!, customizedInitialLayoutAttributes attributes: UICollectionViewLayoutAttributes!, sectionController: ListSectionController!, at index: Int) -> UICollectionViewLayoutAttributes! {
        print("test")
        return attributes
    }
    
    func listAdapter(_ listAdapter: ListAdapter!, customizedFinalLayoutAttributes attributes: UICollectionViewLayoutAttributes!, sectionController: ListSectionController!, at index: Int) -> UICollectionViewLayoutAttributes! {
        return attributes
    }
}

extension PostSectionController: ListWorkingRangeDelegate {
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerWillEnterWorkingRange sectionController: ListSectionController) {
        guard let controller = sectionController as? PostSectionController else {
            fatalError()
        }
        
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerDidExitWorkingRange sectionController: ListSectionController) {
        //pass
    }
    
    
}

