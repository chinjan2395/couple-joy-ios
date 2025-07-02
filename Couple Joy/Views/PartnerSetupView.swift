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
            } else if !isAuthenticated {
                VStack(spacing: 20) {
                    Text("You’re signed out")
                        .font(.title2)
                        .bold()
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

                Text("Select your role so we can pair you with your partner.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                HStack(spacing: 24) {
                    ForEach(["partnerA", "partnerB"], id: \.self) { role in
                        let isSelected = roleSelection == role

                        VStack(spacing: 8) {
                            Image(systemName: role == "partnerA" ? "person.fill" : "person.fill.viewfinder")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                                .foregroundColor(isSelected ? .white : .gray)

                            Text(role == "partnerA" ? "Partner A" : "Partner B")
                                .font(.headline)
                                .foregroundColor(isSelected ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(isSelected ? AppColors.accentPink : Color(.systemGray6))
                                .shadow(color: isSelected ? .pink.opacity(0.3) : .clear,
                                        radius: isSelected ? 10 : 0)
                        )
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                roleSelection = role
                            }
                        }
                    }
                }
                .padding(.horizontal)

                VStack(spacing: 12) {
                    Text("Your Code: \(tempCoupleId)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    
                    TextField("Enter Couple ID", text: Binding(
                        get: { String(tempCoupleId) },
                        set: { tempCoupleId = $0.uppercased() }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.top, 6)
                }

            if isSaving {
                ProgressView()
            } else {
                Button("Continue") {
                    continueSetup()
                }
                .disabled(
                    tempCoupleId.trimmingCharacters(in: .whitespaces).isEmpty
                        || roleSelection.isEmpty
                )
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.accentPink)
                .foregroundColor(.white)
                .cornerRadius(AppCorners.medium)
                .padding(.horizontal)
            }
        }
        .padding(.top, 32)
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
