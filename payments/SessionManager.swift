import SwiftUI

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var username: String = ""

    func logIn(token: String, username: String) {
        KeychainHelper.shared.save(key: "authToken", value: token)
        self.username = username
        isLoggedIn = true
    }

    func logOut() {
        KeychainHelper.shared.delete(key: "authToken")
        self.username = ""
        isLoggedIn = false
    }
}
