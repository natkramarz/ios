//
//  TestAppUITests.swift
//  TestAppUITests
//
//  Created by Natalia Kramarz on 28/01/2025.
//

import XCTest

extension XCUIElement {
    func clearText() {
        guard let currentValue = self.value as? String else { return }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        self.tap()
        self.typeText(deleteString)
    }
}

final class TestAppUITests: XCTestCase {
    
    
    func testLoginSuccess() {
        let app = XCUIApplication()
        app.launch()
        
        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("test@example.com")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        loginButton.tap()
        
        XCTAssertTrue(app.staticTexts["welcomeMessage"].exists)
    }
    
    func testEmptyFields() {
        let app = XCUIApplication()
        app.launch()
        
        let loginButton = app.buttons["loginButton"]
        loginButton.tap()
        
        XCTAssertTrue(app.staticTexts["errorMessage"].exists)
        XCTAssertEqual(app.staticTexts["errorMessage"].label, "Email and password cannot be empty.")
    }
    
    func testEmptyEmail() {
        let app = XCUIApplication()
        app.launch()
        
        let passwordField = app.secureTextFields["passwordField"]
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        let loginButton = app.buttons["loginButton"]
        loginButton.tap()
        
        XCTAssertTrue(app.staticTexts["errorMessage"].exists)
        XCTAssertEqual(app.staticTexts["errorMessage"].label, "Email and password cannot be empty.")
    }
    
    func testEmptyPasswordSuccess() {
        let app = XCUIApplication()
        app.launch()
        
        let emailField = app.textFields["emailField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("test@example.com")
        
        loginButton.tap()
        
        XCTAssertTrue(app.staticTexts["errorMessage"].exists)
        XCTAssertEqual(app.staticTexts["errorMessage"].label, "Email and password cannot be empty.")
    }

    func testInvalidCredentials() {
        let app = XCUIApplication()
        app.launch()
        
        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("wrong@example.com")
        
        passwordField.tap()
        passwordField.typeText("wrongPassword")
        
        loginButton.tap()
        
        XCTAssertTrue(app.staticTexts["errorMessage"].exists)
        XCTAssertEqual(app.staticTexts["errorMessage"].label, "Invalid email or password.")
    }
    
    func testLoginViewExists() {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.textFields["emailField"].exists)
        XCTAssertTrue(app.secureTextFields["passwordField"].exists)
        XCTAssertTrue(app.buttons["loginButton"].exists)
    }
    
    func testShowPasswordButtonRevealsPassword() {
        let app = XCUIApplication()
        app.launch()
        
        let passwordSecureField = app.secureTextFields["passwordField"]
        let showPasswordButton = app.buttons["showPasswordButton"]

        XCTAssertTrue(passwordSecureField.exists)
        XCTAssertTrue(showPasswordButton.exists)
            
        passwordSecureField.tap()
        passwordSecureField.typeText("mySecurePassword")

        showPasswordButton.tap()

        let passwordTextField = app.textFields["passwordField"]
        XCTAssertTrue(passwordTextField.exists)
        XCTAssertEqual(passwordTextField.value as? String, "mySecurePassword")
    }
    
    func testHidePasswordAgain() {
        let app = XCUIApplication()
        app.launch()
        
        let passwordSecureField = app.secureTextFields["passwordField"]
        let showPasswordButton = app.buttons["showPasswordButton"]

        XCTAssertTrue(passwordSecureField.exists)
        XCTAssertTrue(showPasswordButton.exists)

        passwordSecureField.tap()
        passwordSecureField.typeText("mySecurePassword")

        showPasswordButton.tap()
        let passwordTextField = app.textFields["passwordField"]
        XCTAssertTrue(passwordTextField.exists)

        showPasswordButton.tap()
        let passwordHiddenField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordHiddenField.exists)
    }
    
    func testPasswordFieldIsSecureByDefault() {
        let app = XCUIApplication()
        app.launch()
        let passwordSecureField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordSecureField.exists)
    }

    func testForgotPasswordDisplaysResetMessage() {
        let app = XCUIApplication()
        app.launch()
        
        let forgotPasswordButton = app.buttons["forgotPasswordButton"]
        let errorMessage = app.staticTexts["errorMessage"]

        XCTAssertTrue(forgotPasswordButton.exists)
            
        forgotPasswordButton.tap()
            
            
        XCTAssertTrue(errorMessage.exists)
        XCTAssertEqual(errorMessage.label, "Password reset link sent!")
    }

    func testForgotPasswordMultipleClicks() {
        let app = XCUIApplication()
        app.launch()
        
        let forgotPasswordButton = app.buttons["forgotPasswordButton"]
        let errorMessage = app.staticTexts["errorMessage"]

        XCTAssertTrue(forgotPasswordButton.exists)
            
        forgotPasswordButton.tap()
            
        XCTAssertTrue(errorMessage.exists)
        XCTAssertEqual(errorMessage.label, "Password reset link sent!")

        
        forgotPasswordButton.tap()

        XCTAssertTrue(errorMessage.exists)
        XCTAssertEqual(errorMessage.label, "Password reset link sent!")
    }
    
    func testLoginWithCorrectCredentialsResetsErrorMessage() {
        
        let app = XCUIApplication()
        app.launch()
        
        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]
        let errorMessage = app.staticTexts["errorMessage"]
        let welcomeMessage = app.staticTexts["welcomeMessage"]

        emailField.tap()
        emailField.typeText("wrong@example.com")
            
        passwordField.tap()
        passwordField.typeText("wrongPassword")
            
        loginButton.tap()
            
        XCTAssertTrue(errorMessage.exists)
        XCTAssertEqual(errorMessage.label, "Invalid email or password.")

        emailField.tap()
        emailField.clearText()
        emailField.typeText("test@example.com")
            
        passwordField.tap()
        passwordField.clearText()
        passwordField.typeText("password123")
            
        loginButton.tap()

        XCTAssertFalse(errorMessage.exists)

        XCTAssertTrue(welcomeMessage.exists)
    }
}
