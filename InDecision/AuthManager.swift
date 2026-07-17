//
//  AuthManager.swift
//  InDecision
//
//  Created by Jacob Gellard on 17/7/2026.
//

import Combine
import Foundation
import Supabase

@MainActor
final class AuthManager: ObservableObject {
    @Published private(set) var isSignedIn = false
    @Published private(set) var userID: UUID?
    @Published private(set) var userEmail: String?
    @Published var errorMessage = ""
    @Published var isLoading = false

    private let client = SupabaseManager.shared.client

    func refreshSession() async {
        do {
            let user = try await client.auth.user()
            updateSession(userID: user.id, email: user.email)
        } catch {
            clearSession()
        }
    }

    func handleOAuthCallback(url: URL) async {
        do {
            let session = try await client.auth.session(from: url)
            updateSession(userID: session.user.id, email: session.user.email)
            print("OAuth login complete")
        } catch {
            errorMessage = error.localizedDescription
            clearSession()
            print("OAuth callback failed:", error)
        }
    }

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = ""

        do {
            try await client.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "indecision://login-callback")
            )
            print("Google OAuth started")
        } catch {
            errorMessage = error.localizedDescription
            print("Google login failed:", error)
        }

        isLoading = false
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = ""

        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )
            updateSession(userID: response.user.id, email: response.user.email)
            print("Created user:", response.user.id)
        } catch {
            errorMessage = error.localizedDescription
            print(error)
        }

        isLoading = false
    }

    func createProfile(username: String) async {
        do {
            let user = try await client.auth.session.user

            let profile = Profile(
                id: user.id,
                username: username,
                full_name: nil
            )

            try await client
                .from("profiles")
                .insert(profile)
                .execute()
        } catch {
            errorMessage = error.localizedDescription
            print(error)
        }
    }

    func signOut() async {
        do {
            try await client.auth.signOut()
            clearSession()
        } catch {
            errorMessage = error.localizedDescription
            print("Sign out failed:", error)
        }
    }

    private func updateSession(userID: UUID, email: String?) {
        self.userID = userID
        self.userEmail = email
        isSignedIn = true
        errorMessage = ""
    }

    private func clearSession() {
        userID = nil
        userEmail = nil
        isSignedIn = false
    }
}
