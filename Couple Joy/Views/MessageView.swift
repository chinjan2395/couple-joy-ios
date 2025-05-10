//
//  MessageView.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 10/05/25.
//  Messaging interface (chat)

import SwiftUI
import Firebase

struct MessageView: View {
    let coupleId: String
    let partnerRole: String
    let userId: String

    @State private var listener: ListenerRegistration?
    @State private var lastMessage: Message?
    @State private var newMessage: String = ""
    @State private var currentTime = Date()

    var partnerDocument: String {
        return partnerRole == "partnerA" ? "partnerB" : "partnerA"
    }

    var senderInitial: String {
        return String(partnerDocument.uppercased().prefix(1))
    }

    var body: some View {
        VStack(spacing: 16) {
            if let message = lastMessage {
                MessageBubbleView(
                    message: message,
                    partnerInitial: String(partnerDocument.prefix(1)),
                    currentTime: currentTime,
                )
            } else {
                Text("No message yet")
                    .foregroundColor(.gray)
            }

            HStack {
                TextField("Type your message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.currentTime = Date()
            }
            listenForLastMessage(currentRole: partnerRole)
        }
    }

    func listenForLastMessage(currentRole: String) {
        listener = FirestoreManager.shared.listenToPartnerMessage(
            coupleId: coupleId,
            currentRole: partnerRole
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
}
