//
//  SignInView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 17/7/2026.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager

    // Theme Colors matching the rest of the app
    private let bgTeal = Color("AppSurface")
    private let accentGreen = Color("ColorGreen")

    var body: some View {
        ZStack {
            // 1. Background Layers
            bgTeal.ignoresSafeArea()
            
            // Bottom Right Staggered Shape
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        accentGreen.frame(width: 130, height: 70)
                        accentGreen.frame(width: 250, height: 70)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)

            // 2. Main Content
            VStack(spacing: 24) {
                Spacer()
                
                // App Logo/Icon representation
                Image(systemName: "person.3.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)

                Text("Welcome to Bloop")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("Sign in to create and join experiences")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                // Google Sign-In Button
                Button {
                    Task {
                        await authManager.signInWithGoogle()
                    }
                } label: {
                    HStack(spacing: 10) {
                        if authManager.isLoading {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 20))
                            Text("Continue with Google")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                }
                .disabled(authManager.isLoading)
                .opacity(authManager.isLoading ? 0.7 : 1)
                .padding(.horizontal, 24)

                if !authManager.errorMessage.isEmpty {
                    Text(authManager.errorMessage)
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
