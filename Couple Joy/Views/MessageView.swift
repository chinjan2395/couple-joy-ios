//
//  MessageView.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 10/05/25.
//  Messaging interface (chat)

import Firebase
import FirebaseAuth
import SwiftUI

struct MessageView: View {
    let coupleId: String
    let partnerRole: PartnerRole
    let userId: String

    @State private var listener: ListenerRegistration?
    @State private var lastMessage: Message?
    @State private var newMessage: String = ""
    @State private var currentTime = Date()

    @Environment(\.dismiss) private var dismiss

    // These match the keys used in PartnerSetupView
    @AppStorage("partnerRole") private var storedPartnerRole: String = ""
    @AppStorage("partnerInitial") private var storedPartnerInitial: String = ""
    @AppStorage("coupleId") private var storedCoupleId: String = ""

    var partnerDocument: String {
        return partnerRole.opposite.rawValue
    }

    var ownerInitial: String {
        return partnerRole.owner.shortLabel
    }

    var partnerInitial: String {
        return partnerRole.opposite.shortLabel
    }

    var body: some View {
        VStack(spacing: 16) {
            // Partner Avatar & Couple ID
            VStack(spacing: 8) {
                // Partner Initial Circle
                Text(ownerInitial)
                    .font(.system(size: 36, weight: .bold))
                    .frame(width: 80, height: 80)
                    .background(AppColors.accentPink)
                    .clipShape(Circle())
                    .foregroundColor(AppColors.white)
                    .shadow(color: AppColors.accentPink.opacity(0.4), radius: 8)

                // Subtle Couple ID
                Text("Couple ID: \(coupleId)")
                    .font(AppFonts.subtitleFont())
                    .foregroundColor(AppColors.textSecondary)
            }

            // Last Message or Placeholder
            if let message = lastMessage {
                MessageBubbleView(
                    message: message,
                    partnerInitial: partnerInitial,
                    currentTime: currentTime,
                )
            } else {
                Text("No message yet")
                    .foregroundColor(AppColors.textSecondary)
            }

            // Prompt
            Text("Send a sweet message to your partner…")
                .font(.body)
                .foregroundColor(AppColors.textSecondary)

            HStack {
                TextField("Type something lovely...", text: $newMessage)
                    .padding()
                    .background(AppColors.white)
                    .cornerRadius(AppCorners.extraLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCorners.extraLarge)
                            .stroke(AppColors.accentPink, lineWidth: 2)
                    )
                    .foregroundColor(AppColors.textPrimary)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            newMessage.isEmpty
                                ? AppColors.buttonDisabled
                                : AppColors.accentPink
                        )
                        .clipShape(Circle())
                }
                .disabled(newMessage.isEmpty)
            }
            .padding(.horizontal)

            Spacer()

            // Reset Setup
            VStack {
                Divider()
                Text("Want to start fresh?")
                    .font(.footnote)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical, 8)

                Button(action: resetSetup) {
                    Text("Reset Setup")
                        .foregroundColor(AppColors.textPrimary)
                        .fontWeight(.medium)
                        .padding(.horizontal, AppSpacing.large)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCorners.large)
                                .stroke(AppColors.accentPink, lineWidth: 2)
                        )
                }
            }
            .padding(.top, 4)
        }
        .padding(.bottom)
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.currentTime = Date()
            }
            listenForLastMessage(currentRole: partnerRole.rawValue)
        }
    }

    func listenForLastMessage(currentRole: String) {
        listener = FirestoreManager.shared.listenToPartnerMessage(
            coupleId: coupleId,
            currentRole: PartnerRole(rawValue: currentRole)!
        ) { partnerMessage in
            self.lastMessage = partnerMessage
        }
    }

    func sendMessage() {
        guard
            !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }

        FirestoreManager.shared.sendMessage(
            coupleId: coupleId,
            role: partnerRole,
            message: newMessage
        ) { error in
            if let error = error {
                print("Failed to send message: \(error)")
            } else {
                newMessage = ""
            }
        }
    }

    private func resetSetup() {
        // Clear stored data
        storedPartnerRole = ""
        storedPartnerInitial = ""
        storedCoupleId = ""

        try? Auth.auth().signOut()

        dismiss()
    }
}
