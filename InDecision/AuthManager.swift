//
//  AuthManager.swift
//  InDecision
//
//  Created by Jacob Gellard on 17/7/2026.
//

import Combine
import Foundation
import UIKit
import Supabase

@MainActor
final class AuthManager: ObservableObject {

    @Published private(set) var isSignedIn = false
    @Published private(set) var userID: UUID?
    @Published private(set) var userEmail: String?
    @Published private(set) var profile: Profile?

    @Published var avatarImage: UIImage?
    @Published var isLoadingAvatar = false

    @Published private(set) var needsProfileSetup = false
    @Published var errorMessage = ""
    @Published var isLoading = false

    private let client = SupabaseManager.shared.client

    // MARK: - Session

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

            updateSession(
                userID: session.user.id,
                email: session.user.email
            )

            await loadProfile()

            print("OAuth login complete")

        } catch {
            errorMessage = error.localizedDescription
            clearSession()
            print("OAuth callback failed:", error)
        }
    }

    // MARK: - Authentication

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = ""

        do {
            let session = try await client.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "indecision://login-callback")
            )

            updateSession(
                userID: session.user.id,
                email: session.user.email
            )

            await loadProfile()

            print("Google OAuth complete:", session.user.id)

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

            updateSession(
                userID: response.user.id,
                email: response.user.email
            )

            await loadProfile()

            print("Created user:", response.user.id)

        } catch {
            errorMessage = error.localizedDescription
            print(error)
        }

        isLoading = false
    }


    // MARK: - Profile

    func loadProfile() async {

        guard let userID else {
            profile = nil
            avatarImage = nil
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


            // Automatically load avatar
            if let avatarURL = profiles.first?.avatar_url {
                await loadAvatar(from: avatarURL)
            } else {
                avatarImage = nil
            }


        } catch {

            profile = nil
            avatarImage = nil
            needsProfileSetup = true
            errorMessage = error.localizedDescription

            print("Profile load failed:", error)
        }
    }


    // MARK: - Avatar Loading

    func loadAvatar(from urlString: String) async {
        isLoadingAvatar = true
        avatarImage = await SupabaseManager.shared.loadAvatarImage(from: urlString)
        isLoadingAvatar = false
    }



    // MARK: - Create Profile

    func createProfile(username: String, fullName: String?) async {

        guard let userID else {
            errorMessage = "You need to sign in before creating a profile."
            return
        }


        let trimmedUsername =
        username.trimmingCharacters(in: .whitespacesAndNewlines)

        let trimmedFullName =
        fullName?.trimmingCharacters(in: .whitespacesAndNewlines)


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
                full_name: trimmedFullName?.isEmpty == true
                    ? nil
                    : trimmedFullName,
                avatar_url: nil,
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
                    avatar_url: profile.avatar_url,
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


    // MARK: - Sign Out

    func signOut() async {

        do {

            try await client.auth.signOut()
            clearSession()

        } catch {

            errorMessage = error.localizedDescription
            print("Sign out failed:", error)
        }
    }



    // MARK: - Helpers

    private func updateSession(
        userID: UUID,
        email: String?
    ) {

        self.userID = userID
        self.userEmail = email
        isSignedIn = true
        errorMessage = ""
    }


    private func clearSession() {

        userID = nil
        userEmail = nil
        profile = nil
        avatarImage = nil
        needsProfileSetup = false
        isSignedIn = false
    }
}
