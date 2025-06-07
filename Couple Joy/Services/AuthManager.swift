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
        case .missingClientID: return "Missing Firebase client ID."
        case .noRootViewController: return "Root view controller not found."
        case .invalidGoogleUser: return "Google user data is invalid."
        case .notAuthenticated: return "User is not authenticated."
        case .userNotAuthenticated: return "User is not authenticated. Please sign in again."
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
