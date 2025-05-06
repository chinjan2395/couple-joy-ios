//
//  CoupleJoyWidget.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 07/05/25.
//

import Foundation
import WidgetKit
import SwiftUI

//@main
struct CoupleJoyWidget: Widget {
    let kind: String = "CoupleJoyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CoupleJoyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Partner Message")
        .description("Displays the latest message from your partner.")
        .supportedFamilies([.systemSmall, .systemMedium]) // You can add .systemLarge if needed
    }
}
