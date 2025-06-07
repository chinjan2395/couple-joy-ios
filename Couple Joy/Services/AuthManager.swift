//
//  AuthManager.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 11/05/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

enum AuthError: LocalizedError {
    case userNotAuthenticated
    case missingClientID
    case noRootViewController
    case invalidGoogleUser
    case notAuthenticated

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
    
    enum AuthError: LocalizedError {
            case missingClientID
            case noRootViewController
            case invalidGoogleUser
            case notAuthenticated

            var errorDescription: String? {
                switch self {
                case .missingClientID: return "Missing Firebase client ID."
                case .noRootViewController: return "Root view controller not found."
                case .invalidGoogleUser: return "Google user data is invalid."
                case .notAuthenticated: return "User is not authenticated."
                }
            }
        }

    private init() {}

    var isAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }

    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    func signInWithGoogle(completion: @escaping (Error?) -> Void) {
            GIDSignIn.sharedInstance.signOut()
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                completion(AuthError.missingClientID)
                return
            }

            let config = GIDConfiguration(clientID: clientID)

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                completion(AuthError.noRootViewController)
                return
            }

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    completion(error)
                    return
                }

                guard
                    let authentication = result?.user,
                    let idToken = authentication.idToken?.tokenString
                else {
                    completion(AuthError.invalidGoogleUser)
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken.tokenString)

                Auth.auth().signIn(with: credential) { result, error in
                    completion(error)
                }
            }
        }

    func requireAuth(completion: (Result<String, AuthError>) -> Void) {
        if let uid = currentUserID {
            completion(.success(uid))
        } else {
            completion(.failure(.notAuthenticated))
        }
    }
}
