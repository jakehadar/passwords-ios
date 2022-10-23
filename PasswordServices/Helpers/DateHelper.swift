//
//  DateHelper.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import Foundation

public class DateHelper {
    public static func toInt(_ date: Date) -> Int {
        let timeInterval = date.timeIntervalSince1970
        return Int(timeInterval)
    }
    
    public static func fromInt(_ int: Int) -> Date {
        let timeInterval = Double(int)
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    public static func timeIntervalString(since date: Date) -> String {
        let rightNow = DateHelper.toInt(Date())
        let backThen = DateHelper.toInt(date)
        
        let seconds = rightNow - backThen
        if seconds < 60 { return "\(seconds) seconds" }
        
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes) minutes" }
        
        let hours = minutes / 60
        if hours < 24 { return "\(hours) hours" }
        
        let days = hours / 24
        if days < 7 { return "\(days) days" }
        
        let weeks = days / 7
        if weeks < 4 { return "\(weeks) weeks" }
        
        let months = days / 30
        if months < 12 { return "\(months) months"}
        
        let years = days / 365
        return "\(years) years"
    }
}
