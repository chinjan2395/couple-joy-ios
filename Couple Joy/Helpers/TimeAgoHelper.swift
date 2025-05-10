//
//  TimeAgoHelper.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 10/05/25.
//

import Foundation

func timeAgo(from: Date, to currentDate: Date) -> String {
    let interval = Int(currentDate.timeIntervalSince(from))

    if interval < 60 {
        return "\(interval) sec ago"
    } else if interval < 3600 {
        return "\(interval / 60) min ago"
    } else if interval < 86400 {
        return "\(interval / 3600) hr ago"
    } else {
        return "\(interval / 86400) day ago"
    }
}
