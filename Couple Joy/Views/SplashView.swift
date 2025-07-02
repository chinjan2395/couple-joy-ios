//
//  SplashView.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 02/07/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var animateLogo = false
    @State private var animateBackground = false
    @State private var gradientPhase: CGFloat = 0.0
    
    // Match final app background
    let finalColors = [Color.pink.opacity(0.35), Color.purple.opacity(0.25), Color.blue.opacity(0.4)]
    let splashColors = [Color.pink.opacity(0.2), Color.blue.opacity(0.25), Color.purple.opacity(0.3)]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ZStack {
                // Animated gradient with blend toward final background
                            LinearGradient(
                                gradient: Gradient(colors: interpolatedColors),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .ignoresSafeArea()
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateBackground)

            // Logo & Title
            if !isActive {
                VStack(spacing: 20) {
                    Image(systemName: "heart.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .scaleEffect(animateLogo ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animateLogo)

                    Text("CoupleJoy")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(animateLogo ? 1 : 0.8)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animateLogo)
                }
            } else {
                BackgroundWrapper {
                    ContentView()
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            animateLogo = true

            // Trigger animation for background
            withAnimation {
                animateBackground = true
            }

            // Switch to app view
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isActive = true
                }
            }
        }
    }
    // Linear interpolation between splash and final colors
       var interpolatedColors: [Color] {
           zip(splashColors, finalColors).map { splash, final in
               Color.lerp(from: splash, to: final, fraction: gradientPhase)
           }
       }
}

#Preview {
    SplashView()
}
