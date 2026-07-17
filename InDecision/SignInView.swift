//
//  SignInView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 17/7/2026.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome")
                .font(.largeTitle)
                .bold()

            Text("Sign in to create and join experiences")
                .foregroundColor(.secondary)

            Button {
                Task {
                    await authManager.signInWithGoogle()
                }
            } label: {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "g.circle.fill")
                        Text("Continue with Google")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(authManager.isLoading)

            if !authManager.errorMessage.isEmpty {
                Text(authManager.errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(AuthManager())
    }
}
