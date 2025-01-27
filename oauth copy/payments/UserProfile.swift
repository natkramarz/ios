import SwiftUI


struct UserProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var currentView: ProfileViewState = .login

    var body: some View {
        VStack {
            switch currentView {
            case .login:
                LoginView(onRegister: {
                    currentView = .register
                }, onLoginSuccess: {
                    currentView = .profile
                })
            case .register:
                RegisterView(onRegisterSuccess: {
                    currentView = .profile
                }, onCancel: {
                    currentView = .login
                })
            case .profile:
                ProfileDetailView(onLogout: {
                    sessionManager.logOut()
                    currentView = .login
                })
            }
        }
    }
}

enum ProfileViewState {
    case login, register, profile
}

struct LoginView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var password = ""
    @State private var errorMessage: String?
    let onRegister: () -> Void
    let onLoginSuccess: () -> Void

    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("Username", text: $sessionManager.username)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("Log In") {
                authenticate()
            }
            .padding()

            Button("Don't have an account? Register") {
                onRegister()
            }
            .padding()
        }
        .padding()
    }

    func authenticate() {
        guard let url = URL(string: "http://127.0.0.1:8000/login") else {
            errorMessage = "Invalid URL"
            return
        }

        let loginDetails = [
            "username": sessionManager.username,
            "password": password
        ]
        
        password = ""
        
        guard let body = try? JSONSerialization.data(withJSONObject: loginDetails) else {
            errorMessage = "Failed to encode login details"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data in response"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = json["token"] as? String {
                        DispatchQueue.main.async {
                            sessionManager.logIn(token: token, username: sessionManager.username)
                            errorMessage = nil
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorMessage = "Invalid response format"
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = "Failed to parse response"
                    }
                }
                onLoginSuccess()
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Invalid credentials"
                }
            }
        }.resume()
    }
}



struct RegisterView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var password = ""
    @State private var errorMessage: String?
    let onRegisterSuccess: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack {
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("Username", text: $sessionManager.username)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("Register") {
                register()
            }
            .padding()

            Button("Cancel") {
                onCancel()
            }
            .padding()
        }
        .padding()
    }

    func register() {
        guard let url = URL(string: "http://127.0.0.1:8000/register") else {
            errorMessage = "Invalid URL"
            return
        }

        let registrationDetails = [
            "username": sessionManager.username,
            "password": password
        ]

        password = ""

        guard let body = try? JSONSerialization.data(withJSONObject: registrationDetails) else {
            errorMessage = "Failed to encode registration details"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data in response"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = json["token"] as? String {
                        DispatchQueue.main.async {
                            sessionManager.logIn(token: token, username: sessionManager.username)
                            errorMessage = nil
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorMessage = "Invalid response format"
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = "Failed to parse response"
                    }
                }
                onRegisterSuccess()
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Registration failed"
                }
            }
        }.resume()
    }
}



struct ProfileDetailView: View {
    @EnvironmentObject var sessionManager: SessionManager
    let onLogout: () -> Void

    var body: some View {
        VStack {
            Text("My Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("Username: \(sessionManager.username)")
                .font(.title)

            Button("Log Out") {
                onLogout()
            }
            .padding()
        }
    }
}
