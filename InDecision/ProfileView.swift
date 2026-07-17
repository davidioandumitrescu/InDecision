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
            if authManager.isSignedIn {
                ProfileView()
            } else {
                SignInView()
            }
        }
        .task {
            await authManager.refreshSession()
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.black)

            Text("Profile")
                .font(.largeTitle)
                .bold()

            if let email = authManager.userEmail {
                Text(email)
                    .foregroundColor(.secondary)
            }

            Button("Sign Out") {
                Task {
                    await authManager.signOut()
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
