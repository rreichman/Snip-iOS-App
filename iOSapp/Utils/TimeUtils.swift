//
//  TimeUtils.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/11/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation

class TimeUtils {
    
    static var dateFormatter: DateFormatter = DateFormatter()
    
    static func olderThanFourteenDays(date: Date) -> Bool {
        let fourteenDayTimeInterval: TimeInterval = 24*60*60 * 14
        let fourteenDaysAgo = Date().addingTimeInterval(-fourteenDayTimeInterval)
        let comparison = date.compare(fourteenDaysAgo)
        return comparison == .orderedAscending
    }
    
    static func olderThanOneDay(date: Date) -> Bool {
        let oneDayTimeInterval: TimeInterval = 24*60*60
        let onDayAgo = Date().addingTimeInterval(-oneDayTimeInterval)
        let comparison = date.compare(onDayAgo)
        return comparison == .orderedAscending
    }
    
    static func getFormattedDateString(date: Date) -> String {
        TimeUtils.dateFormatter.timeStyle = .none
        TimeUtils.dateFormatter.dateStyle = .short
        
        if TimeUtils.olderThanFourteenDays(date: date) {
            return TimeUtils.dateFormatter.string(from: date)
        } else if TimeUtils.olderThanOneDay(date: date) {
            let components = Calendar.current.dateComponents([.day], from: date, to: Date())
            guard let day = components.day else { return TimeUtils.dateFormatter.string(from: date) }
            return "\(day)d"
        } else {
            let components = Calendar.current.dateComponents([.hour, .minute], from: date, to: Date())
            guard let min = components.minute, let hr = components.hour else { return TimeUtils.dateFormatter.string(from: date) }
            if hr == 0 {
                return "\(min)m"
            } else {
                return "\(hr)h"
            }
        }
    }
}

