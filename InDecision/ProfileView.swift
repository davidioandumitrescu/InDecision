//
//  ProfileView.swift
//  InDecision
//
//  Created by Jacob Gellard on 17/7/2026.
//

import SwiftUI

struct ProfileDestinationView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        Group {
            if !authManager.isSignedIn {
                SignInView()
            } else if authManager.needsProfileSetup {
                ProfileSetupView()
            } else {
                ProfileView()
            }
        }
        .task {
            await authManager.refreshSession()
        }
    }
}

struct ProfileSetupView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var fullName = ""

    var body: some View {
        Form {
            Section {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                TextField("Full name", text: $fullName)
                    .textContentType(.name)
            } header: {
                Text("Create Profile")
            } footer: {
                Text("Your profile is linked to your signed-in account.")
            }

            if let email = authManager.userEmail {
                Section("Account") {
                    Text(email)
                        .foregroundColor(.secondary)
                }
            }

            if !authManager.errorMessage.isEmpty {
                Section {
                    Text(authManager.errorMessage)
                        .foregroundColor(.red)
                }
            }

            Section {
                Button {
                    Task {
                        await authManager.createProfile(
                            username: username,
                            fullName: fullName
                        )
                    }
                } label: {
                    if authManager.isLoading {
                        ProgressView()
                    } else {
                        Text("Continue")
                    }
                }
                .disabled(authManager.isLoading || username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Set Up Profile")
    }
}

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var eventManager: EventManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.black)

            if let profile = authManager.profile {
                Text(profile.full_name ?? profile.username)
                    .font(.largeTitle)
                    .bold()

                Text("@\(profile.username)")
                    .foregroundColor(.secondary)
            } else {
                Text("Profile")
                    .font(.largeTitle)
                    .bold()
            }

            if let email = authManager.userEmail {
                Text(email)
                    .foregroundColor(.secondary)
            }

            Button("Sign Out") {
                Task {
                    await authManager.signOut()
                    eventManager.clearSavedEvents()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationStack {
        ProfileDestinationView()
            .environmentObject(AuthManager())
    }
}
