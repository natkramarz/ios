//
//  ContentView.swift
//  TestApp
//
//  Created by Natalia Kramarz on 28/01/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            LoginView()
        }
        .padding()
    }
}


struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var showPassword: Bool = false
    @State private var isLoginButtonDisabled: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .bold()
            TextField("Email", text: $email, onEditingChanged: { _ in validateInput()})
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .accessibilityIdentifier("emailField")
            
            HStack {
                if showPassword {
                    TextField("Password", text: $password, onEditingChanged: { _ in
                        validateInput()
                    })
                    .accessibilityIdentifier("passwordField")
                } else {
                    SecureField("Password", text: $password, onCommit: validateInput)
                        .autocapitalization(.none)
                        .accessibilityIdentifier("passwordField")
                }
                
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .accessibilityIdentifier("showPasswordButton")
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: login) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("loginButton")
            
            Button(action: forgotPassword) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
            }
            .accessibilityIdentifier("forgotPasswordButton")
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .accessibilityIdentifier("errorMessage")
            }
            
            if isLoggedIn {
                Text("Welcome!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .accessibilityIdentifier("welcomeMessage")
            }
            
            Spacer()
        }
        .padding()
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func login() {
        if email.isEmpty || password.isEmpty {
            isLoggedIn = false
            errorMessage = "Email and password cannot be empty."
        } else if !isValidEmail(email) {
            isLoggedIn = false
            errorMessage = "Invalid email format."
        } else if email == "test@example.com" && password == "password123" {
            errorMessage = ""
            isLoggedIn = true
        } else {
            isLoggedIn = false
            errorMessage = "Invalid email or password."
        }
    }
    
    private func forgotPassword() {
        errorMessage = "Password reset link sent!"
    }
    
    private func validateInput() {
        isLoginButtonDisabled = email.isEmpty || password.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}




#Preview {
    ContentView()
}
