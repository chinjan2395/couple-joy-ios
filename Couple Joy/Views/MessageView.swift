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
    @State private var showHeart = false
    @State private var heartScale: CGFloat = 0.8
    @State private var showResetConfirmation = false

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
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.gradientPinkStart, AppColors.gradientPinkEnd]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: AppColors.gradientPinkEnd.opacity(0.4), radius: 10)

                    Text(ownerInitial)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }

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
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(AppCorners.medium)
            }

            // Prompt
            Text("Send a sweet message to your partner…")
                .font(.body)
                .foregroundColor(AppColors.white)

            ZStack {
                // Floating Heart Animation
                if showHeart {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 30))
                        .foregroundColor(AppColors.gradientPinkStart)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .scaleEffect(heartScale)
                        .offset(y: 100)
                }
                
                // Input Section
                HStack {
                   TextField("Message", text: $newMessage)
                       .padding()
                       .background(.ultraThinMaterial)
                       .cornerRadius(AppCorners.extraLarge)
                       .foregroundColor(AppColors.white)
                       .overlay(
                           RoundedRectangle(cornerRadius: AppCorners.extraLarge)
                               .stroke(Color.clear, lineWidth: 0) // No border
                       )

                    Button(action: {
                        sendMessage()
                        withAnimation(.easeOut(duration: 0.5)) {
                            showHeart = true
                            heartScale = 1.5
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeIn(duration: 0.3)) {
                                showHeart = false
                                heartScale = 0.8
                            }
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                newMessage.isEmpty
                                ? AppColors.buttonDisabled
                                : AppColors.gradientPinkStart
                            )
                            .clipShape(Circle())
                    }
                    .disabled(newMessage.isEmpty)
                }
                .padding(.horizontal)
            }

            Spacer()

            // Reset Setup
            VStack(spacing: 8) {
                Divider()

                Text("Want to start fresh?")
                    .font(.footnote)
                    .foregroundColor(AppColors.textSecondary)

                Button(action: {
                    showResetConfirmation = true
                }) {
                    Text("Reset Setup")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.large)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: AppCorners.large)
                                .stroke(AppColors.gradientPinkStart, lineWidth: 1.5)
                        )
                }
                .alert("Reset Setup?", isPresented: $showResetConfirmation) {
                    Button("Reset", role: .destructive, action: resetSetup)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will clear your couple setup and sign you out. Are you sure?")
                }
            }
            .padding(.top, 12)
        }
        .padding(.bottom)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                currentTime = Date()
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
        
        // Mark setup as incomplete
        AuthManager.shared.isSetupComplete = false

        try? Auth.auth().signOut()

        dismiss()
    }
}
