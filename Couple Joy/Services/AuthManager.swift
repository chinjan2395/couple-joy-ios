//
//  AuthManager.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 11/05/25.
//

import Foundation
import FirebaseAuth

enum AuthError: LocalizedError {
    case userNotAuthenticated

    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated. Please sign in again."
        }
    }
}

class AuthManager {
    static let shared = AuthManager()

    private init() {}

    var isAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }

    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }

    func requireAuth(completion: (Result<String, AuthError>) -> Void) {
        if let uid = currentUserID {
            completion(.success(uid))
        } else {
            completion(.failure(.userNotAuthenticated))
        }
    }
}
