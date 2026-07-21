//
//  ProfileView.swift
//  InDecision
//
//  Created by Jacob Gellard on 17/7/2026.
//

//import SwiftUI
//
//struct ProfileDestinationView: View {
//    @EnvironmentObject var authManager: AuthManager
//
//    var body: some View {
//        Group {
//            if !authManager.isSignedIn {
//                SignInView()
//            } else if authManager.needsProfileSetup {
//                ProfileSetupView()
//            } else {
//                ProfileView()
//            }
//        }
//        .task {
//            await authManager.refreshSession()
//        }
//    }
//}
//
//struct ProfileSetupView: View {
//    @EnvironmentObject var authManager: AuthManager
//    @State private var username = ""
//    @State private var fullName = ""
//
//    var body: some View {
//        Form {
//            Section {
//                TextField("Username", text: $username)
//                    .textInputAutocapitalization(.never)
//                    .autocorrectionDisabled()
//
//                TextField("Full name", text: $fullName)
//                    .textContentType(.name)
//            } header: {
//                Text("Create Profile")
//            } footer: {
//                Text("Your profile is linked to your signed-in account.")
//            }
//
//            if let email = authManager.userEmail {
//                Section("Account") {
//                    Text(email)
//                        .foregroundColor(.secondary)
//                }
//            }
//
//            if !authManager.errorMessage.isEmpty {
//                Section {
//                    Text(authManager.errorMessage)
//                        .foregroundColor(.red)
//                }
//            }
//
//            Section {
//                Button {
//                    Task {
//                        await authManager.createProfile(
//                            username: username,
//                            fullName: fullName
//                        )
//                    }
//                } label: {
//                    if authManager.isLoading {
//                        ProgressView()
//                    } else {
//                        Text("Continue")
//                    }
//                }
//                .disabled(authManager.isLoading || username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//            }
//        }
//        .navigationTitle("Set Up Profile")
//    }
//}
//
//struct ProfileView: View {
//    @EnvironmentObject var authManager: AuthManager
//    @EnvironmentObject var eventManager: EventManager
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: "person.crop.circle.fill")
//                .font(.system(size: 72))
//                .foregroundColor(.black)
//
//            if let profile = authManager.profile {
//                Text(profile.full_name ?? profile.username)
//                    .font(.largeTitle)
//                    .bold()
//
//                Text("@\(profile.username)")
//                    .foregroundColor(.secondary)
//            } else {
//                Text("Profile")
//                    .font(.largeTitle)
//                    .bold()
//            }
//
//            if let email = authManager.userEmail {
//                Text(email)
//                    .foregroundColor(.secondary)
//            }
//
//            Button("Sign Out") {
//                Task {
//                    await authManager.signOut()
//                    eventManager.clearSavedEvents()
//                }
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .padding()
//        .navigationTitle("Profile")
//    }
//}
//
//#Preview {
//    NavigationStack {
//        ProfileDestinationView()
//            .environmentObject(AuthManager())
//    }
//}

import SwiftUI
import PhotosUI
import Supabase

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

// MARK: - NEW PROFILE VIEW

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.dismiss) var dismiss
    
    
    

    // Theme Colors matching the mockup
    private let bgTeal = Color.teal
    private let accentGreen = Color.green
    private let btnPurple = Color(red: 0.45, green: 0.35, blue: 0.95)
    
    // UI State
    @State private var interests: [String] = ["Sport", "Adventure"]
    @State private var selectedItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var isUploadingAvatar = false
    
    // Computed Data
    var myEvents: [DetailedEvent] {
        guard let uid = authManager.userID else { return [] }
        return eventManager.events.filter { $0.created_by == uid }
    }
    
    var historyEvents: [DetailedEvent] {
        eventManager.events.filter { eventManager.joinedEventIDs.contains($0.id) }
    }

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
            
            // 2. Main Content Layer
            VStack(alignment: .leading, spacing: 0) {
                headerBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        profileHeader
                        
                        interestsSection
                        
                        Divider().background(Color.white.opacity(0.3))
                        
                        createdEventsSection
                        
                        Divider().background(Color.white.opacity(0.3))
                        
                        historyEventsSection
                        
                        Spacer(minLength: 40)
                        
                        signOutButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 60)
                    .padding(.top, 10)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        
    }
    
    // MARK: - SUBSECTIONS
    
    private var headerBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .bold))
                    Text("Back")
                        .font(.system(size: 22, weight: .bold))
                }
                .foregroundColor(.white)
            }
            
            Spacer()
            
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(.white)
        }
        .padding(.top, 16)
    }
    
    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            ZStack(alignment: .bottomTrailing) {

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images
                ) {
                    if let avatarImage = authManager.avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(btnPurple, lineWidth: 4)
                            )
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(4)
                            .background(bgTeal)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(btnPurple, lineWidth: 4)
                            )
                    }
                }
                .disabled(isUploadingAvatar)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .background(btnPurple)
                    .clipShape(Circle())
                    .offset(x: 5, y: 5)
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    await loadAvatar(from: newItem)
                }
            }


            VStack(alignment: .leading, spacing: 4) {
                if let profile = authManager.profile {
                    Text(profile.full_name ?? profile.username)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }

                if let email = authManager.userEmail {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
    
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Interests")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black.opacity(0.6))
            
            HStack(spacing: 10) {
                ForEach(interests, id: \.self) { interest in
                    Text(interest)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Capsule())
                }
                
                // "Add Tag" Button
                Button(action: {
                    // Placeholder for adding a new tag functionality
                    interests.append("New Tag")
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private func loadAvatar(from item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data)
            else {
                return
            }

            await MainActor.run {
                avatarImage = image
                isUploadingAvatar = true
            }

            guard let userID = authManager.userID else {
                return
            }

            let path = "\(userID.uuidString)/avatar.jpg"
            
            
            try await SupabaseManager.shared.client.storage
                .from("avatars")
                .upload(
                    path,
                    data: data,
                    options: FileOptions(
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )
                
            
            print("Uploading path:", path)
            print("User ID:", userID.uuidString)

            let url = try SupabaseManager.shared.client.storage
                .from("avatars")
                .getPublicURL(path: path)

            try await SupabaseManager.shared.client
                .from("profiles")
                .update([
                    "avatar_url": url.absoluteString
                ])
                .eq("id", value: userID)
                .execute()

            await MainActor.run {
                isUploadingAvatar = false
            }

            print("✅ Avatar uploaded")
            
            await authManager.refreshSession()

        } catch {
            await MainActor.run {
                isUploadingAvatar = false
            }

            print("❌ Avatar upload failed:", error)
        }
    }
    
    private var createdEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Events")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black.opacity(0.6))
            
            if myEvents.isEmpty {
                Text("You haven't created any events yet.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(myEvents) { event in
                            NavigationLink(destination: ExperienceDetailView(event: event, bgColor: bgTeal, nextColor: accentGreen)) {
                                miniEventCard(for: event)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var historyEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black.opacity(0.6))
            
            if historyEvents.isEmpty {
                Text("You haven't joined any events yet.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(historyEvents) { event in
                            NavigationLink(destination: ExperienceDetailView(event: event, bgColor: bgTeal, nextColor: accentGreen)) {
                                miniEventCard(for: event)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var signOutButton: some View {
        Button(action: {
            Task {
                await authManager.signOut()
                eventManager.clearSavedEvents()
            }
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
            }
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(btnPurple)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    // Reusable view for the mini event pills in the horizontal scroll views
    private func miniEventCard(for event: DetailedEvent) -> some View {
        HStack(spacing: 8) {
            Text(event.activity.isEmpty ? "Something fun" : event.activity)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.3))
        .clipShape(Capsule())
    }
}
