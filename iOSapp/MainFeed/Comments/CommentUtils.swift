//
//  CommentUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 12/4/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

func getCommentArraySortedAndReadyForPresentation(commentArray : [Comment]) -> [Comment]
{
    let allCommentsNested : [Comment] = turnCommentArrayIntoNestedComments(allCommentsArray: commentArray)
    var commentsNotNested : [Comment] = []
    
    // Note - If comments were deeper, recursion would probably make sense but not worth it now
    for comment in allCommentsNested
    {
        commentsNotNested.append(comment)
        for commentOnLevelOne in comment.subComments
        {
            commentsNotNested.append(commentOnLevelOne)
            for commentOnLevelTwo in commentOnLevelOne.subComments
            {
                commentsNotNested.append(commentOnLevelTwo)
            }
        }
    }
    
    return commentsNotNested
}

func turnCommentArrayIntoNestedComments(allCommentsArray : [Comment]) -> [Comment]
{
    let allCommentsNested : [Comment] = getCommentsWithGivenParent(allCommentsArray: allCommentsArray, parent: 0)
    for commentOnLevelZero in allCommentsNested
    {
        commentOnLevelZero.subComments = getCommentsWithGivenParent(allCommentsArray: allCommentsArray, parent: commentOnLevelZero.id)
        for commentOnLevelOne in commentOnLevelZero.subComments
        {
            // Note - If comments were deeper, recursion would probably make sense but not worth it now
            commentOnLevelOne.subComments = getCommentsWithGivenParent(allCommentsArray: allCommentsArray, parent: commentOnLevelOne.id)
        }
    }
    return allCommentsNested
}

func getCommentsWithGivenParent(allCommentsArray : [Comment], parent: Int) -> [Comment]
{
    var subComments : [Comment] = []
    for comment in allCommentsArray
    {
        if comment.parent == parent
        {
            subComments.append(comment)
        }
    }
    return subComments
}
