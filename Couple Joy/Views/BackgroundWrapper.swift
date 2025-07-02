//
//  BackgroundWrapper.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 02/07/25.
//

import SwiftUI

struct BackgroundWrapper<Content: View>: View {
    let content: () -> Content
    var body: some View {
            ZStack {
                AnimatedBackground()
                content()
            }
        }
}

#Preview {
    BackgroundWrapper(content: { Text("Hello World!") })
}
