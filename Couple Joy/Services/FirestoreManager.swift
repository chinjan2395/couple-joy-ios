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
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard !coupleId.isEmpty else {
            print("Error: coupleId is empty in isPartnerRoleAvailable")
            completion(
                .failure(
                    NSError(
                        domain: "Input",
                        code: 400,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Couple ID is empty."
                        ]
                    )
                )
            )
            return
        }
        AuthManager.shared.requireAuth { result in
                switch result {
                case .failure(let error):
                    print("Auth Error: \(error.localizedDescription)")
                    completion(.failure(error))

                case .success(let uid):
                    let partnerARoleRef = self.partnerDoc(coupleId: coupleId, role: .partnerA)
                    let partnerBRoleRef = self.partnerDoc(coupleId: coupleId, role: .partnerB)

                    partnerARoleRef.getDocument { docA, _ in
                        partnerBRoleRef.getDocument { docB, _ in
                            let uidA = docA?.data()?["uid"] as? String
                            let uidB = docB?.data()?["uid"] as? String

                            // CASE 1: Same user already selected *any* role → allow only reselect
                            if (uidA == uid || uidB == uid) {
                                if (uidA == uid && role != .partnerA) || (uidB == uid && role != .partnerB) {
                                    completion(.success(false))
                                } else {
                                    completion(.success(true))
                                }
                            }
                            // CASE 2: Someone else already took this role → deny
                            else if (role == .partnerA && uidA != nil) || (role == .partnerB && uidB != nil) {
                                completion(.success(false))
                            }
                            // CASE 3: Available
                            else {
                                completion(.success(true))
                            }
                        }
                    }
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
        AuthManager.shared.requireAuth { result in
            switch result {
            case .success(let uid):
                let data: [String: Any] = [
                    "message": message,
                    "timestamp": FieldValue.serverTimestamp(),
                    "uid": uid,
                    "device": device,
                ]

                partnerDoc(coupleId: coupleId, role: role)
                    .setData(data, merge: true, completion: completion)

            case .failure(let error):
                completion?(error)
            }
        }
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
