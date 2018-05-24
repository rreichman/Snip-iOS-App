//
//  PostContainer.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/24/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class PostContainer: Object {
    dynamic var nextPage: Int?
    let posts = List<Post>()
}
