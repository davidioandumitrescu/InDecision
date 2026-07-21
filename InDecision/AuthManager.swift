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
    @Published private(set) var profile: Profile?
    @Published private(set) var needsProfileSetup = false
    @Published var errorMessage = ""
    @Published var isLoading = false

    private let client = SupabaseManager.shared.client

    func refreshSession() async {
        do {
            let user = try await client.auth.user()
            updateSession(userID: user.id, email: user.email)
            await loadProfile()
        } catch {
            clearSession()
        }
    }

    func handleOAuthCallback(url: URL) async {
        do {
            let session = try await client.auth.session(from: url)
            updateSession(userID: session.user.id, email: session.user.email)
            await loadProfile()
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
            await loadProfile()
            print("Created user:", response.user.id)
        } catch {
            errorMessage = error.localizedDescription
            print(error)
        }

        isLoading = false
    }

    func loadProfile() async {
        guard let userID else {
            profile = nil
            needsProfileSetup = false
            return
        }

        do {
            let profiles: [Profile] = try await client
                .from("profiles")
                .select()
                .eq("id", value: userID.uuidString)
                .limit(1)
                .execute()
                .value

            profile = profiles.first
            needsProfileSetup = profiles.first == nil
            errorMessage = ""
        } catch {
            profile = nil
            needsProfileSetup = true
            errorMessage = error.localizedDescription
            print("Profile load failed:", error)
        }
    }

    func createProfile(username: String, fullName: String?) async {
        guard let userID else {
            errorMessage = "You need to sign in before creating a profile."
            return
        }

        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFullName = fullName?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty else {
            errorMessage = "Choose a username before continuing."
            return
        }

        isLoading = true
        errorMessage = ""

        do {
            let newProfile = Profile(
                id: userID,
                username: trimmedUsername,
                full_name: trimmedFullName?.isEmpty == true ? nil : trimmedFullName,
                interests: []
            )

            try await client
                .from("profiles")
                .insert(newProfile)
                .execute()

            profile = newProfile
            needsProfileSetup = false
        } catch {
            errorMessage = error.localizedDescription
            print("Profile creation failed:", error)
        }

        isLoading = false
    }

    func updateInterests(_ interests: [String]) async -> Bool {
        guard let userID else {
            errorMessage = "You need to sign in before updating your interests."
            return false
        }

        var seenInterests = Set<String>()
        let normalizedInterests = interests.compactMap { interest -> String? in
            let trimmedInterest = interest.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedInterest.isEmpty else { return nil }

            let comparisonKey = trimmedInterest.lowercased()
            guard seenInterests.insert(comparisonKey).inserted else { return nil }
            return trimmedInterest
        }

        isLoading = true
        errorMessage = ""

        do {
            try await client
                .from("profiles")
                .update(["interests": normalizedInterests])
                .eq("id", value: userID.uuidString)
                .execute()

            if let profile {
                self.profile = Profile(
                    id: profile.id,
                    username: profile.username,
                    full_name: profile.full_name,
                    interests: normalizedInterests
                )
            } else {
                await loadProfile()
            }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Interests update failed:", error)
            isLoading = false
            return false
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
        profile = nil
        needsProfileSetup = false
        isSignedIn = false
    }
}
