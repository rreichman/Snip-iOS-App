//
//  SnipScheduler.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/2/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RxSwift

class SnipScheduler {
    static let io: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(qos: .default)

}
