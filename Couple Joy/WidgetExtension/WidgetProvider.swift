//
//  WidgetProvider.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 07/05/25.
//

import Foundation
import WidgetKit
import SwiftUI
import Firebase
import FirebaseFirestore

struct MessageEntry: TimelineEntry {
    let date: Date
    let message: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MessageEntry {
        MessageEntry(date: Date(), message: "Loading...")
    }

    func getSnapshot(in context: Context, completion: @escaping (MessageEntry) -> Void) {
        let entry = MessageEntry(date: Date(), message: "Latest message")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MessageEntry>) -> Void) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        let userId = UserDefaults(suiteName: "group.com.chinjan.couplejoy")?.string(forKey: "userId") ?? "demo"

        let db = Firestore.firestore()
        db.collection("couples").document(userId).getDocument { document, error in
            var latestMessage = "No message found"

            if let doc = document, doc.exists {
                latestMessage = doc.data()?["latestMessage"] as? String ?? "Empty"
            }

            let entry = MessageEntry(date: Date(), message: latestMessage)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

struct CoupleJoyWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.message)
            .padding()
            .font(.headline)
    }
}
