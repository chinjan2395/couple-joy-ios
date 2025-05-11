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
        role: PartnerRole,
        completion: @escaping (Error?) -> Void
    ) {
        guard !coupleId.isEmpty else {
            print("Error: coupleId is empty in savePartnerInfo")
            completion(
                NSError(
                    domain: "",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid couple ID"]
                )
            )
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(
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
            "device": device,
            "uid": uid,
            "timestamp": FieldValue.serverTimestamp(),
        ]

        partnerDoc(coupleId: coupleId, role: role)
            .setData(data, merge: true) { error in
                completion(error)
            }
    }
    
    // MARK: - Check Partner Availibility
    func isPartnerRoleAvailable(
        coupleId: String,
        role: PartnerRole,
        completion: @escaping (Bool) -> Void
    ) {
        guard !coupleId.isEmpty else {
                    print("Error: coupleId is empty in isPartnerRoleAvailable")
                    completion(false)
                    return
                }
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated")
                    completion(false)
                    return
        }
        partnerDoc(coupleId: coupleId, role: role)
            .getDocument { document, error in
                if let document = document, document.exists {
                    // Role is already taken
                    print("document")
                    print(document.data() as Any)
                    if (document.data()?["uid"] as! String != uid) {
                        print("This partner is already registered. Please choose the other.")
                        completion(false)
                    } else {
                        print("else of partnerDoc")
                        completion(true)
                    }
                } else {
                    // Role is available
                    completion(true)
                }
            }
    }
    
    
    // MARK: - Store Message in Firbase
    func sendMessage(
        coupleId: String,
        role: PartnerRole,
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

        partnerDoc(coupleId: coupleId, role: role)
            .setData(data, merge: true, completion: completion)
    }

    // MARK: - Listen to Last Partner Message
    func listenToPartnerMessage(
        coupleId: String,
        currentRole: PartnerRole,
        completion: @escaping (Message?) -> Void
    ) -> ListenerRegistration {
        let partnerRole = currentRole.opposite

        return partnerDoc(coupleId: coupleId, role: partnerRole)
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

    private func partnerDoc(coupleId: String, role: PartnerRole) -> DocumentReference
    {
        return db.collection("couples")
            .document(coupleId)
            .collection("roles")
            .document(role.rawValue)
    }
}
