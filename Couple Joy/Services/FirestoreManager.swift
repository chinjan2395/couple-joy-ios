//
//  FirestoreManager.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 09/05/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    func sendMessage(coupleId: String, role: String, message: String, completion: ((Error?) -> Void)? = nil) {
        let deviceName = UIDevice.current.name
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let data: [String: Any] = [
            "message": message,
            "timestamp": FieldValue.serverTimestamp(),
            "uid": uid,
            "device": deviceName
        ]
        
        db.collection("couples")
            .document(coupleId)
            .collection("roles")
            .document(role)
            .setData(data, merge: true, completion: completion)
    }
    
    func observeMessage(coupleId: String, partnerRole: String, onUpdate: @escaping (_ text: String?, _ timestamp: Date?) -> Void) {
        db.collection("couples")
            .document(coupleId)
            .collection("roles")
            .document(partnerRole)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data(),
                      let message = data["message"] as? String,
                      let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
                          onUpdate(nil, nil)
                          return
                      }
                onUpdate(message, timestamp)
            }
    }
}
