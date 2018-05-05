//
//  SingleBackgroundThread.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RxSwift

class SingleBackgroundThread {
    static let scheduler: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(qos: .default)
}
