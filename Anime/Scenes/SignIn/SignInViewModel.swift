//
//  SignInViewModel.swift
//  Anime
//
//  Created by elene malakmadze on 02.02.26.
//

import Foundation

final class SignInViewModel {
    private let userRepository = UserRepository.shared

    enum AuthMode {
        case signIn
        case signUp
    }

    var authMode: AuthMode = .signIn

    var onError: ((String) -> Void)?
    var onSuccess: ((User) -> Void)?

    func authenticate(username: String, password: String) {
        guard validateInput(username: username, password: password) else {
            return
        }

        switch authMode {
        case .signIn:
            signIn(username: username, password: password)
        case .signUp:
            signUp(username: username, password: password)
        }
    }

    private func signIn(username: String, password: String) {
        if !userRepository.userExists(username: username) {
            onError?("Account not found. Please sign up first.")
            return
        }

        if let user = userRepository.login(username: username, password: password) {
            onSuccess?(user)
        } else {
            onError?("Invalid password")
        }
    }

    private func signUp(username: String, password: String) {
        if userRepository.userExistsWithCredentials(username: username, password: password) {
            onError?("You are already signed up. Please sign in instead.")
            return
        }

        if userRepository.userExists(username: username) {
            onError?("Username already exists")
            return
        }

        if let user = userRepository.createUser(username: username, password: password) {
            onSuccess?(user)
        } else {
            onError?("Failed to create account")
        }
    }

    private func validateInput(username: String, password: String) -> Bool {
        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            onError?("Username is required")
            return false
        }

        if username.count < 3 {
            onError?("Username must be at least 3 characters")
            return false
        }

        if password.isEmpty {
            onError?("Password is required")
            return false
        }

        if password.count < 4 {
            onError?("Password must be at least 4 characters")
            return false
        }

        if !password.contains(where: { $0.isNumber }) {
            onError?("Password must contain at least one number")
            return false
        }

        return true
    }
}
