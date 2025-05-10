//
//  Couple_JoyApp.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 06/05/25.
//

import SwiftUI

@main
struct Couple_JoyApp: App {
    // 👇 inject AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
