import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

struct ContentView: View {
//    @State private var message = ""
    @State private var isSignedIn = false
    @State private var userId: String?
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        VStack(spacing: 20) {
            if authManager.isLoading {
                ProgressView("Loading...")
            } else if authManager.isSignedIn {
                PartnerSetupView(userId: userId ?? "")
            } else {
                VStack {
//                    Text(AuthError.notAuthenticated.localizedDescription)
                    Button(action: handleSignInButton) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                            Text("Sign in with Google")
                        }
                        .frame(width: 220, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                        }
            }
        }
        // Auth listener should only be set up once
//        .onAppear {
//            authManager.setupAuthListener()
//        }
    }

    func handleSignInButton() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Missing clientID")
            return
        }

        _ = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("No rootViewController found")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Google Sign-In result invalid")
                return
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Firebase Auth error: \(error.localizedDescription)")
                    return
                }

                self.userId = result?.user.uid
                self.isSignedIn = true
                UserDefaults(suiteName: "group.com.chinjan.couplejoy")?.set(self.userId, forKey: "userId")
            }
        }
    }
}
