//
//  FirestoreManager.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 09/05/25.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    let device = UIDevice.current.name

    private init() {}

    // MARK: - Partner Setup
    func savePartnerInfo(
        coupleId: String,
        role: String,
        completion: @escaping (Error?) -> Void
    ) {
        let data: [String: Any] = [
            "device": device,
            "timestamp": FieldValue.serverTimestamp(),
        ]

        db.collection("couples")
            .document(coupleId)
            .collection("roles")
            .document(role)
            .setData(data, merge: true) { error in
                completion(error)
            }
    }

    func sendMessage(
        coupleId: String,
        role: String,
        message: String,
        completion: ((Error?) -> Void)? = nil
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(
                NSError(
                    domain: "Auth",
                    code: 401,
                    userInfo: [
                        NSLocalizedDescriptionKey: "User not authenticated"
                    ]
                )
            )
            return
        }

        let data: [String: Any] = [
            "message": message,
            "timestamp": FieldValue.serverTimestamp(),
            "uid": uid,
            "device": device,
        ]

        db.collection("couples")
            .document(coupleId)
            .collection("roles")
            .document(role)
            .setData(data, merge: true, completion: completion)
    }

    func observeMessage(
        coupleId: String,
        partnerRole: String,
        onUpdate: @escaping (_ text: String?, _ timestamp: Date?) -> Void
    ) {
        db.collection("couples")
            .document(coupleId)
            .collection("roles")
            .document(partnerRole)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data(),
                    let message = data["message"] as? String,
                    let timestamp = (data["timestamp"] as? Timestamp)?
                        .dateValue()
                else {
                    onUpdate(nil, nil)
                    return
                }
                onUpdate(message, timestamp)
            }
    }

    // MARK: - Listen to Last Partner Message
    func listenToPartnerMessage(
        coupleId: String,
        currentRole: String,
        completion: @escaping (Message?) -> Void
    ) -> ListenerRegistration {
        let partnerRole = currentRole == "partnerA" ? "partnerB" : "partnerA"

        return db.collection("couples")
            .document(coupleId)
            .collection("roles")
            .document(partnerRole)
            .addSnapshotListener { snapshot, error in
                guard (snapshot?.data()) != nil else {
                    completion(nil)
                    return
                }

                do {
                    let message = try snapshot?.data(as: Message.self)
                    completion(message)
                } catch {
                    print("Decoding error: \(error)")
                    completion(nil)
                }
            }
    }
}
