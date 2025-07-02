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
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Welcome to")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))

                        Text("CoupleJoy")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Button(action: handleSignInButton) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                                .imageScale(.large)
                            Text("Sign in with Google")
                                .fontWeight(.semibold)
                        }
                        .frame(minWidth: 240, minHeight: 50)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule().strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                        .shadow(radius: 6)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .transition(.opacity.combined(with: .scale))
            }
            }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: authManager.isSignedIn)
        .onAppear {
            if authManager.isSignedIn {
                authManager.checkSetupCompletion()
            }
        }
    }

    func handleSignInButton() {
        authManager.signInIfNeeded()
    }
}
