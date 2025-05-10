//
//  TimeAgoHelper.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 10/05/25.
//

import Foundation

func timeAgo(from date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    return formatter.localizedString(for: date, relativeTo: Date())
}
