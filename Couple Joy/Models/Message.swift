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
    var message: String
    var timestamp: Date
    var uid: String
    var device: String
//    var senderInitial: String

    init(id: String? = nil, message: String, timestamp: Date, uid: String, device: String, senderInitial: String? = nil) {
        self.id = id
        self.message = message
        self.timestamp = timestamp
        self.uid = uid
        self.device = device
//        self.senderInitial = senderInitial
    }
}
