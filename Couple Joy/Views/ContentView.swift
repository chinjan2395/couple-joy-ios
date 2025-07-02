import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct ContentView: View {
    @State private var isSignedIn = false
    @State private var userId: String?
    @AppStorage("coupleId") private var storedCoupleId: String = ""
    
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        ZStack {
            if authManager.isLoading || authManager.isCheckingSetup {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .transition(.opacity)
            } else if authManager.isSignedIn {
                if authManager.isSetupComplete && !storedCoupleId.isEmpty {
                    MessageView(
                        coupleId: storedCoupleId,
                        partnerRole: PartnerRole(rawValue: UserDefaults.standard.string(forKey: "partnerRole") ?? "") ?? .partnerA,
                        userId: authManager.currentUserID ?? ""
                    )
                    .transition(.opacity)
                } else {
                    PartnerSetupView(userId: authManager.currentUserID ?? "")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            } else {
                VStack {
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
        }.onAppear {
            if authManager.isSignedIn {
                authManager.checkSetupCompletion()
            }
        }
    }

    func handleSignInButton() {
        authManager.signInIfNeeded()
    }
}
