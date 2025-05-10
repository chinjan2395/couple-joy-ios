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
    let isFromPartner: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if isFromPartner {
                // Partner Initial Circle
                Text(String("A").uppercased())
//                Text(String(message.senderUID.prefix(1)).uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Color.pink)
                    .clipShape(Circle())
            }

            VStack(alignment: isFromPartner ? .leading : .trailing, spacing: 4) {
                Text(message.text)
                    .padding(10)
                    .background(isFromPartner ? Color.gray.opacity(0.2) : Color.blue.opacity(0.7))
                    .foregroundColor(isFromPartner ? .black : .white)
                    .cornerRadius(12)

                if let date = message.timestamp as Date?{
                    Text(timeAgo(from: date))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            if !isFromPartner {
                Spacer(minLength: 30)
            }
        }
        .frame(maxWidth: .infinity, alignment: isFromPartner ? .leading : .trailing)
        .padding(.horizontal)
        .padding(.top, 4)
    }
}
