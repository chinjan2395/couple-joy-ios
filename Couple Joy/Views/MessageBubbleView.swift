//
//  MessageBubbleView.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 10/05/25.
//

import SwiftUI
import FirebaseFirestore

struct MessageBubbleView: View {
    let message: Message
    let partnerInitial: String
    let currentTime: Date

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.pink)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(partnerInitial.uppercased())
                        .foregroundColor(.white)
                        .font(.headline)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(message.message)
                    .font(.body)

                Text(timeAgo(from: message.timestamp, to: currentTime))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
//        .frame(maxWidth: .infinity, alignment: isFromPartner ? .leading : .trailing)
        .padding(.horizontal)
        .padding(.top, 4)
    }
}
