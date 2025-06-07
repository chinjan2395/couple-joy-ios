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

    let userId: String

    var body: some View {
        VStack(spacing: 20) {
            if checkingAuth {
                ProgressView("Checking authentication...")
            } else if !isAuthenticated {
                VStack(spacing: 20) {
                    Text("You're signed out")
                        .font(.title2)
                        .bold()
                    Button("Sign In Again") {
                        AuthManager.shared.signInWithGoogle { error in
                            if error == nil {
                                isAuthenticated = true
                            } else {
                                print("Error saving partner info: \(error?.localizedDescription)")
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
                    coupleId = tempCoupleId  // update the actual @AppStorage value
                    print(
                        "coupleId \(coupleId) /r/ roleSelection \(roleSelection)"
                    )
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
                                        if let error = error {
                                            self.errorMessage = "Internal error. Please try again later."
                                            self.showingError = true
                                        } else {
                                            savePartnerInfo()
                                        }
                                    }
                                } else {
                                    self.errorMessage = "This role is already selected by your partner. Please choose the other one."
                                    self.showingError = true
                                }
                                
                            case .failure(let error):
                                self.errorMessage = error.localizedDescription
                                self.showingError = true
                            }
                        }
                    }
                }
                .disabled(tempCoupleId.isEmpty || roleSelection.isEmpty)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
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
            tempCoupleId = coupleId  // Pre-fill if already saved
            roleSelection = selectedRole
        }
    }

    private func savePartnerInfo() {
        isSaving = true
        coupleId = tempCoupleId
        selectedRole = roleSelection

        FirestoreManager.shared.savePartnerInfo(
            coupleId: tempCoupleId,
            role: PartnerRole(rawValue: roleSelection)!,
        ) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error = error {
                    print("Error saving partner info: \(error)")
                } else {
                    showMessageScreen = true
                }
            }
        }
    }
}

//#Preview {
//    PartnerSetupView(userId: <#String#>)
//}
