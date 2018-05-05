//
//  DateFmt.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation

class DateFmt {
    static let instance: DateFmt = DateFmt()
    
    let dateFormatter: DateFormatter = DateFormatter()
    init() {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
    }
    
    func fmt(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
