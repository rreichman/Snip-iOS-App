//
//  PostDetailSectionController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/23/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class PostDetailSectionController: ListBindingSectionController<PostDetailViewModel>, ListBindingSectionControllerDataSource {
    var model: PostDetailViewModel?
    
    weak var delegate: PostInteractionDelegate?
    weak var commentDelegate: CommentCollectionDelegate?
    
    let edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? PostDetailViewModel else { fatalError() }
        self.model = object
        
        var result: [ListDiffable] = [ PostExpandedViewModel(id: object.id, title: object.title, subhead: object.subhead, body: object.body, authorName: object.authorName, dateString: object.dateString, saved: object.saved, imageUrl: object.imageUrl, voteValue: object.voteValue, urlString: object.urlString, numberOfComments: object.numberOfComments, authorUsername: object.authorUsername, authorAvatarUrl: object.authorAvatarUrl, authorInitials: object.authorInitials)]
        
        result.append(contentsOf: object.comments)
        return result
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        switch viewModel {
        case is PostExpandedViewModel:
            guard let cell = collectionContext?.dequeueReusableCell(withNibName: "PostDetailCollectionCell", bundle: nil, for: self, at: index) as? PostDetailCollectionCell else { fatalError() }
            cell.delegate = self.delegate
            return cell
        case is CommentViewModel:
            guard let cell = collectionContext?.dequeueReusableCell(withNibName: "CommentCollectionCell", bundle: nil, for: self, at: index) as? CommentCollectionCell else { fatalError() }
            cell.commentDelegate = self.commentDelegate
            return cell
        default:
            fatalError()
        }
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { fatalError() }
        switch viewModel {
        case is PostExpandedViewModel:
            guard let model = viewModel as? PostExpandedViewModel else { fatalError() }
            /**
             Top Padding: 16
             Image Height: 2/3 * (screen width - 32)
             Padding: 20
             Container: 30
             Padding: 10
             Title Height
             Padding: 10
             Subheadline height
             Body height
             Padding: 10
             Vote Control: 44
             Padding : 20
             Divider: 1
             Padding: 20
             number of comments: 21
            **/
            let imageHeight = (width - 32) * 0.666
            let titleHeight = TextSize.size(model.title, font: UIFont.latoBold(size: 16), width: width, insets: self.edgeInsets).height
            let subheadlineHeight = TextSize.sizeAttributed(model.subhead, font: UIFont.lato(size: 15), width: width, insets: self.edgeInsets).height
            let bodyHeight = TextSize.sizeAttributed(model.body, font: UIFont.lato(size: 14), width: width, insets: self.edgeInsets).height
            let height = imageHeight + titleHeight + subheadlineHeight + bodyHeight + 212
            print("calculated height for PostDetailSectionController \(height)")
            return CGSize(width: width, height: height)
        case is CommentViewModel:
            guard let model = viewModel as? CommentViewModel else { fatalError() }
            /**
             Padding: 10
             Name: 18
             padding: 5
             Body Height
             padding: 10
             Stack View: 18
             padding: 10
             
             left insets: 16 leading, width: 30,  10 trailing, indent: (10 * comment level)
             right insets: 16 trailing
             **/
            
            let leftIndet: CGFloat = CGFloat.init(integerLiteral: 56 + (10 * model.level))
            // Add 10 becuase TextSize can't manage different line heights in the same text string
            let bodyHeight = TextSize.size(model.body, font: UIFont.lato(size: 15), width: width, insets: UIEdgeInsets(top: 0, left: leftIndet, bottom: 0, right: 16)).height + 10
            
            return CGSize(width: width, height: bodyHeight + 71)
        default:
            fatalError()
        }
    }
    
    override func numberOfItems() -> Int {
        guard let model = self.model else { return 0 }
        return 1 + model.comments.count
    }
    
    override init() {
        super.init()
        dataSource = self
    }
    
    func scrollToComment(index: Int, scrollPosition: UICollectionViewScrollPosition, andimated: Bool) {
        if let context = collectionContext, let model = self.model, index < model.comments.count {
            context.scroll(to: self, at: index + 1, scrollPosition: scrollPosition, animated: andimated)
        }
    }
    
    func scrollToCommentId(commentId: Int, scrollPosition: UICollectionViewScrollPosition, andimated: Bool) {
        if let context = collectionContext, let model = self.model {
            let index = model.comments.index { (commentViewModel: CommentViewModel) -> Bool in
                return commentViewModel.id == commentId
            }
            if let i = index {
                context.scroll(to: self, at: i + 1, scrollPosition: scrollPosition, animated: andimated)
            }
            
        }
    }
}
