//
//  AnimatedBackground.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 02/07/25.
//

import SwiftUI

struct AnimatedBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Circle()
                .fill(Color.pink.opacity(0.4))
                .frame(width: 300, height: 300)
                .offset(x: animate ? -100 : -150, y: animate ? -150 : -100)
                .blur(radius: 80)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)

            Circle()
                .fill(Color.purple.opacity(0.35))
                .frame(width: 260, height: 260)
                .offset(x: animate ? 100 : 150, y: animate ? 150 : 100)
                .blur(radius: 80)
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animate)

            Circle()
                .fill(Color.blue.opacity(0.25))
                .frame(width: 250, height: 250)
                .offset(x: animate ? 0 : 50, y: animate ? -120 : -60)
                .blur(radius: 100)
                .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    AnimatedBackground()
}
