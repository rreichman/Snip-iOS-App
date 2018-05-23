//
//  VoteState.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
enum VoteState {
    case none
    case like
    case dislike
    case value(vote_value: Double)
}
