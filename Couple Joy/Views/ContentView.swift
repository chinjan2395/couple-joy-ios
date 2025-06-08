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
        authManager.signInIfNeeded()
    }
}
