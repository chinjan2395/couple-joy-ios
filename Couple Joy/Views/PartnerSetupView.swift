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
    @State private var tempCoupleId = ""
    @State private var roleSelection = ""
    @State private var showMessageScreen = false
    @State private var isSaving = false

    @State private var errorMessage = ""
    @State private var showingError = false

    let userId: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Setup Your Partner Role")
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
                    savePartnerInfo()
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
                partnerRole: PartnerRole(rawValue: selectedRole)!,
                userId: userId
            )
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
