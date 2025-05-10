//
//  Message.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 10/05/25.
//  Data model for Firestore messages

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var timestamp: Date
    var uid: String
    var device: String
//    var senderInitial: String

    init(id: String? = nil, text: String, timestamp: Date, uid: String, device: String, senderInitial: String? = nil) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.uid = uid
        self.device = device
//        self.senderInitial = senderInitial
    }
}
