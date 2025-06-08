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
                                errorMessage = "Sign-in failed. Please try again."
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
            print("AUTH CHECK")
            tempCoupleId = coupleId  // Pre-fill if already saved
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
    
    @ViewBuilder
    func mainPartnerSetupView() -> some View {
        VStack(spacing: 20) {
            Text("Setup Your Role")
                .font(.title)

            TextField("Enter Couple ID", text: $tempCoupleId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .textInputAutocapitalization(.never) // Recommended for iOS 15+
                .padding(.horizontal)

            Picker("Select Role", selection: $roleSelection) {
                Text("Partner A").tag("partnerA")
                Text("Partner B").tag("partnerB")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            if isSaving {
                ProgressView()
            } else {
                Button("Continue") {
                    continueSetup()
                }
                .disabled(tempCoupleId.isEmpty || roleSelection.isEmpty)
                .padding()
                .background(AppColors.accentPink)
                .foregroundColor(.white)
                .cornerRadius(AppCorners.medium)
            }
        }
    }

    func continueSetup() {
        coupleId = tempCoupleId
        guard let role = PartnerRole(rawValue: roleSelection) else {
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
                print("coupleid: \(coupleId), role: \(role)")
                print("PartnerRole: \(PartnerRole(rawValue: roleSelection)!)")
                switch result {
                case .success(let available):
                    if available {
                        FirestoreManager.shared.savePartnerInfo(
                            coupleId: coupleId,
                            role: PartnerRole(rawValue: roleSelection)!
                        ) { error in
                            isSaving = false
                            if let error = error {
                                print("Error saving partner info: \(error.localizedDescription)")
                                errorMessage = "Internal error. Please try again later."
                                showingError = true
                            } else {
                                selectedRole = roleSelection
                                showMessageScreen = true
                            }
                        }
                    } else {
                        isSaving = false
                        errorMessage = "This role is already selected by your partner. Please choose the other one."
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
