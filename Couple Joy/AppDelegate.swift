//
//  AppDelegate.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 07/05/25.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleSignIn

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle
    // Required if using Google Sign-In
       func application(_ app: UIApplication, open url: URL,
                        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
           return GIDSignIn.sharedInstance.handle(url)
       }
}
