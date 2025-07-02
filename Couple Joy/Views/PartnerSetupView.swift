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
    @State private var tempCoupleId = "TESTING"
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
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

            Text("Please enter your Couple ID and select your role.")
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 16) {
                TextField("Enter Couple ID", text: $tempCoupleId)
                    .textCase(.uppercase)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                    .frame(maxWidth: 320)

                HStack(spacing: 20) {
                    roleCard(title: "Partner A", tag: "partnerA")
                    roleCard(title: "Partner B", tag: "partnerB")
                }
                .frame(maxWidth: 320)
            }

            if isSaving {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Button("Continue") {
                    continueSetup()
                }
                .disabled(
                    tempCoupleId.trimmingCharacters(in: .whitespaces).isEmpty
                        || roleSelection.isEmpty
                )
                .padding()
                .frame(maxWidth: 280)
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(14)
            }

            Spacer()
        }
        .padding()
    }
    
    // MARK: - Role Card
    @ViewBuilder
    func roleCard(title: String, tag: String) -> some View {
        let isSelected = roleSelection == tag

        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .pink)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.pink : Color.white.opacity(0.15))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.pink, lineWidth: isSelected ? 2 : 1)
                )
        }
        .onTapGesture {
            withAnimation(.spring()) {
                roleSelection = tag
            }
        }
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
