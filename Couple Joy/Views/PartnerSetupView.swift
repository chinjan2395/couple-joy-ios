//
//  PartnerSetupView.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 10/05/25.
//  New SwiftUI partner selection screen

import FirebaseAuth
import SwiftUI

struct PartnerSetupView: View {
    @AppStorage(
        "coupleId",
        store: UserDefaults(suiteName: "group.com.chinjan.couplejoy")
    ) var coupleId = ""
    @AppStorage(
        "partnerRole",
        store: UserDefaults(suiteName: "group.com.chinjan.couplejoy")
    ) var selectedRole = ""

    @State private var navigateToMessages = false
    @State private var tempCoupleId = "testing"
    @State private var roleSelection = ""
    @State private var showMessageScreen = false
    @State private var isSaving = false

    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var isAuthenticated = false
    @State private var checkingAuth = true

    let userId: String

    var body: some View {
        VStack(spacing: 20) {
            if checkingAuth {
                ProgressView("Checking authentication...")
                    .foregroundColor(.white)
            } else if !isAuthenticated {
                VStack(spacing: 20) {
                    Text("You’re signed out")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)

                    Button("Sign In Again") {
                        AuthManager.shared.signInWithGoogle { error in
                            if error == nil {
                                isAuthenticated = true
                            } else {
                                errorMessage =
                                    "Sign-in failed. Please try again."
                                showingError = true
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.accentPink)
                    .foregroundColor(.white)
                    .cornerRadius(AppCorners.medium)
                }
            } else {
                mainPartnerSetupView()
            }
        }
        .padding()
        .fullScreenCover(isPresented: $showMessageScreen) {
            MessageView(
                coupleId: coupleId,
                partnerRole: PartnerRole(rawValue: roleSelection)!,
                userId: userId
            )
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            tempCoupleId = coupleId
            roleSelection = selectedRole

            AuthManager.shared.requireAuth { result in
                DispatchQueue.main.async {
                    checkingAuth = false
                    switch result {
                    case .success:
                        isAuthenticated = true
                    case .failure:
                        isAuthenticated = false
                    }
                }
            }
        }
    }

    // MARK: - Main Setup View
    @ViewBuilder
    func mainPartnerSetupView() -> some View {
        VStack(spacing: 24) {
            Text("Setup Your Role")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Select your role so we can pair you with your partner.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 24) {
                roleCard(title: "Partner A", tag: "partnerA", color: AppColors.accentLight)
                roleCard(title: "Partner B", tag: "partnerB", color: AppColors.accentPink)
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                Text("Your Code: \(tempCoupleId)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))

                TextField("Enter Couple ID", text: Binding(
                    get: { String(tempCoupleId) },
                    set: { tempCoupleId = $0.uppercased() }
                ))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.top, 6)
            }

            if isSaving {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Button(action: continueSetup) {
                    HStack {
                        Spacer()
                        Text("Next")
                            .bold()
                            .foregroundColor(.white)
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: roleSelection.isEmpty
                                ? [Color.gray]
                                : [AppColors.accentPink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(
                        color: roleSelection.isEmpty ? .clear : .pink.opacity(0.4),
                        radius: 8, y: 4
                    )
                    .scaleEffect(roleSelection.isEmpty ? 1.0 : 1.02)
                }
                .disabled(roleSelection.isEmpty)
            }
        }
        .padding()
        .transition(.opacity)
    }
    
    // MARK: - Role Card
    func roleCard(title: String, tag: String, color: Color) -> some View {
        let isSelected = roleSelection == tag

        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                roleSelection = tag
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: tag == "partnerA" ? "person.fill" : "person.fill.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))

                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? color : Color.white.opacity(0.05))
                    .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 8)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Continue Button Logic
    func continueSetup() {
        coupleId = tempCoupleId.trimmingCharacters(in: .whitespaces)

        guard PartnerRole(rawValue: roleSelection) != nil else {
            errorMessage = "Invalid role selection."
            showingError = true
            return
        }

        isSaving = true

        FirestoreManager.shared.isPartnerRoleAvailable(
            coupleId: coupleId,
            role: PartnerRole(rawValue: roleSelection)!
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let available):
                    if available {
                        FirestoreManager.shared.savePartnerInfo(
                            coupleId: coupleId,
                            role: PartnerRole(rawValue: roleSelection)!
                        ) { error in
                            isSaving = false
                            if let error = error {
                                print(
                                    "Error saving partner info: \(error.localizedDescription)"
                                )
                                errorMessage =
                                    "Internal error. Please try again later."
                                showingError = true
                            } else {
                                // Save to UserDefaults
                                UserDefaults.standard.set(coupleId, forKey: "coupleId")
                                UserDefaults.standard.set(roleSelection, forKey: "partnerRole")
                                
                                // Refresh setup status
                                AuthManager.shared.checkSetupCompletion()
                                
                                selectedRole = roleSelection
                                // Mark setup as complete
//                                AuthManager.shared.isSetupComplete = true
                                showMessageScreen = true
                            }
                        }
                    } else {
                        isSaving = false
                        errorMessage =
                            "This role is already selected by your partner. Please choose the other one."
                        showingError = true
                    }

                case .failure(let error):
                    isSaving = false
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                }
            }
        }
    }
}

//#Preview {
//    PartnerSetupView(userId: <#String#>)
//}
