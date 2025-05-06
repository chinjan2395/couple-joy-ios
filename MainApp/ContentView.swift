import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

struct ContentView: View {
    @State private var message = ""
    @State private var isSignedIn = false
    @State private var userId: String?

    var body: some View {
        VStack(spacing: 20) {
            if isSignedIn {
                Text("Send Message to Partner")
                    .font(.title2)

                TextField("Enter your message", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Send") {
                    sendMessage()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                GoogleSignInButton {
                    handleSignInButton()
                }
                .frame(width: 200, height: 50)
            }
        }
        .padding()
    }

    func handleSignInButton() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Missing clientID")
            return
        }

        let config = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("No rootViewController found")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Google Sign-In result invalid")
                return
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Firebase Auth error: \(error.localizedDescription)")
                    return
                }

                // Sign-in successful
                self.userId = result?.user.uid
                self.isSignedIn = true
                UserDefaults(suiteName: "group.com.chinjan.couplejoy")?.set(self.userId, forKey: "userId")
            }
        }
    }


    func sendMessage() {
        guard let userId = userId else { return }

        let db = Firestore.firestore()
        db.collection("messages").document(userId).setData([
            "latestMessage": message,
            "senderUID": userId,
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                print("Message sent.")
                message = ""
            }
        }
    }
}
