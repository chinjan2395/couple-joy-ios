//
//  Theme.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 11/05/25.
//

import Foundation
import SwiftUI

enum AppColors {
    // Android-inspired Material You colors
    static let accent = Color(red: 103 / 255, green: 80 / 255, blue: 164 / 255)  // Indigo 500
    static let accentLight = Color(
        red: 234 / 255,
        green: 221 / 255,
        blue: 255 / 255
    )
    //    static let background = Color(UIColor.systemBackground)
    //    static let textPrimary = Color.primary
    //    static let textSecondary = Color.gray
    static let error = Color.red
    static let background = Color(red: 1.0, green: 0.95, blue: 0.96)  // #FFF1F5
    static let accentPink = Color(red: 0.98, green: 0.81, blue: 0.87)  // #F9CEDF
    static let softGray = Color.gray.opacity(0.6)
    static let buttonDisabled = Color.gray.opacity(0.3)
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
    static let white = Color.white
}

enum AppFonts {
    static func titleFont(size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func bodyFont(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    static func subtitleFont(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}

enum AppSpacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
}

enum AppCorners {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 20
    static let extraLarge: CGFloat = 28
}

enum AppShadows {
    static let light = Color.black.opacity(0.05)
    static let medium = Color.black.opacity(0.1)
    static let heavy = Color.black.opacity(0.2)
}
