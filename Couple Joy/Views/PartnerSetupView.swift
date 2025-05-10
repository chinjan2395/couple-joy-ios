//
//  PartnerSetupView.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 10/05/25.
//  New SwiftUI partner selection screen

import FirebaseAuth
import SwiftUI

struct PartnerSetupView: View {

    @State private var coupleId: String = ""
    @State private var selectedPartnerRole: String = ""
    @State private var navigateToMessages = false

    let userId: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Group ID")
                .font(.title2)

            TextField("e.g. chinjan2024", text: $coupleId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Text("Select Your Role")
                .font(.headline)

            HStack(spacing: 40) {
                Button(action: {
                    selectedPartnerRole = "partnerA"
                }) {
                    Text("Partner A")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedPartnerRole == "partnerA"
                                ? Color.blue : Color.gray.opacity(0.3)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    selectedPartnerRole = "partnerB"
                }) {
                    Text("Partner B")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedPartnerRole == "partnerB"
                                ? Color.pink : Color.gray.opacity(0.3)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            Spacer()

            if !coupleId.isEmpty && !selectedPartnerRole.isEmpty {
                NavigationLink(
                    destination: MessageView(
                        coupleId: coupleId,
                        partnerRole: selectedPartnerRole,
                        userId: userId
                    ),
                    isActive: $navigateToMessages
                ) {
                    Button("Continue") {
                        navigateToMessages = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .navigationTitle("Partner Setup")
    }
}

//#Preview {
//    PartnerSetupView(userId: <#String#>)
//}
