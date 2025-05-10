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

//    @State private var messageText = ""
//    @State private var partnerMessage = ""
    @State private var listener: ListenerRegistration?
    @State private var lastMessage: Message?
    @State private var newMessage: String = ""

    var partnerDocument: String {
        return partnerRole == "partnerA" ? "partnerB" : "partnerA"
    }

    var body: some View {
            VStack(spacing: 16) {
                if let message = lastMessage {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 36, height: 36)
                            .overlay(
//                                Text(message.senderInitial)
                                Text("A")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(message.text)
                                .font(.body)

                            Text(timeAgo(from: message.timestamp))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
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
                listenForLastMessage()
            }
        }

//    func subscribeToPartnerMessage() {
//        let db = Firestore.firestore()
//        listener = db.collection("couples")
//            .document(coupleId)
//            .collection("roles")
//            .document(partnerDocument)
//            .addSnapshotListener { snapshot, error in
//                if let data = snapshot?.data(), let msg = data["message"] as? String {
//                    self.partnerMessage = msg
//                }
//            }
//    }
    
    func listenForLastMessage() {
            let db = Firestore.firestore()
            db.collection("couples")
                .document(coupleId)
                .collection("roles")
                .order(by: "timestamp", descending: true)
                .limit(to: 1)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error listening: \(error.localizedDescription)")
                        return
                    }

                    guard let document = snapshot?.documents.first else {
                        self.lastMessage = nil
                        return
                    }

                    self.lastMessage = try? document.data(as: Message.self)
                }
        }

    func sendMessage() {
            guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

            let db = Firestore.firestore()
            let deviceName = UIDevice.current.name
            let senderInitial = String(partnerRole.uppercased().prefix(1))
            let message = Message(
                text: newMessage,
                timestamp: Date(),
                uid: userId,
                device: deviceName
            )

            do {
                try db.collection("couples")
                    .document(coupleId)
                    .collection("roles")
                    .document(partnerRole)
                    .setData(from: message, merge: true)
//                    .setData(data, merge: true, completion: completion)
//                    .addDocument(from: message)
                newMessage = ""
            } catch {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
}
