//
//  ProfileView.swift
//  InDecision
//
//  Created by Jacob Gellard on 17/7/2026.
//

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

private struct InterestEditorView: View {
    @ObservedObject var authManager: AuthManager
    @Binding var interests: [String]
    @Environment(\.dismiss) private var dismiss

    @State private var draftInterests: [String]

    init(
        authManager: AuthManager,
        interests: Binding<[String]>,
        startsWithEmptyInterest: Bool
    ) {
        self.authManager = authManager
        self._interests = interests

        var initialInterests = interests.wrappedValue
        if startsWithEmptyInterest {
            initialInterests.append("")
        }
        self._draftInterests = State(initialValue: initialInterests)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(draftInterests.indices, id: \.self) { index in
                        TextField(
                            "Interest",
                            text: Binding(
                                get: { draftInterests[index] },
                                set: { draftInterests[index] = $0 }
                            )
                        )
                        .textInputAutocapitalization(.words)
                    }
                    .onDelete { offsets in
                        draftInterests.remove(atOffsets: offsets)
                    }

                    Button {
                        draftInterests.append("")
                    } label: {
                        Label("Add Interest", systemImage: "plus")
                    }
                } footer: {
                    Text("Empty and duplicate interests are removed when you save.")
                }

                if !authManager.errorMessage.isEmpty {
                    Section {
                        Text(authManager.errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Interests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(authManager.isLoading)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            if await authManager.updateInterests(draftInterests) {
                                interests = authManager.profile?.interests ?? []
                                dismiss()
                            }
                        }
                    } label: {
                        if authManager.isLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(authManager.isLoading)
                }
            }
        }
        .interactiveDismissDisabled(authManager.isLoading)
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

private struct FlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let rows = makeRows(maxWidth: proposal.width ?? .infinity, subviews: subviews)
        let contentWidth = rows.map(\.width).max() ?? 0
        let contentHeight = rows.reduce(0) { $0 + $1.height }
            + verticalSpacing * CGFloat(max(rows.count - 1, 0))

        return CGSize(
            width: proposal.width ?? contentWidth,
            height: contentHeight
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = makeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX

            for item in row.items {
                item.subview.place(
                    at: CGPoint(x: x, y: y + (row.height - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + horizontalSpacing
            }

            y += row.height + verticalSpacing
        }
    }

    private func makeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let requiredWidth = currentRow.items.isEmpty
                ? size.width
                : currentRow.width + horizontalSpacing + size.width

            if !currentRow.items.isEmpty, requiredWidth > maxWidth {
                rows.append(currentRow)
                currentRow = Row()
            }

            currentRow.items.append(Item(subview: subview, size: size))
            currentRow.width += (currentRow.items.count == 1 ? 0 : horizontalSpacing) + size.width
            currentRow.height = max(currentRow.height, size.height)
        }

        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }

    private struct Item {
        let subview: LayoutSubview
        let size: CGSize
    }

    private struct Row {
        var items: [Item] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }
}

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var voiceManager: VoiceManager
    @Environment(\.dismiss) var dismiss
    
    
    

    // Theme Colors matching the mockup
    private let bgTeal = Color.mint
    private let accentGreen = Color.green
    private let btnPurple = Color(red: 0.45, green: 0.35, blue: 0.95)
    
    // UI State
    @State private var interests: [String] = []
    @State private var isEditingInterests = false
    @State private var shouldAddInterest = false
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
                        
                        communitySoundSection
                        
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
        .onAppear {
            interests = authManager.profile?.interests ?? []
        }
        .onChange(of: authManager.profile?.interests) { _, updatedInterests in
            interests = updatedInterests ?? []
        }
        .sheet(isPresented: $isEditingInterests) {
            InterestEditorView(
                authManager: authManager,
                interests: $interests,
                startsWithEmptyInterest: shouldAddInterest
            )
        }
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
                    AvatarView(userID: authManager.userID, size: 100)
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
            
            FlowLayout(horizontalSpacing: 10, verticalSpacing: 10) {
                ForEach(Array(interests.enumerated()), id: \.offset) { _, interest in
                    Button {
                        shouldAddInterest = false
                        isEditingInterests = true
                    } label: {
                        Text(interest)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                
                // "Add Tag" Button
                Button(action: {
                    shouldAddInterest = true
                    isEditingInterests = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Add interest")
            }

            if !authManager.errorMessage.isEmpty {
                Text(authManager.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
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

            SupabaseManager.shared.invalidateAvatarCache(for: url.absoluteString)   // <-- new

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
                FlowLayout(horizontalSpacing: 10, verticalSpacing: 10) {
                    ForEach(myEvents) { event in
                        NavigationLink {
                            ExperienceDetailView(
                                event: event,
                                bgColor: bgTeal,
                                nextColor: accentGreen
                            )
                        } label: {
                            miniEventCard(for: event)
                        }
                        .buttonStyle(.plain)
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
                FlowLayout(horizontalSpacing: 10, verticalSpacing: 10) {
                    ForEach(historyEvents) { event in
                        NavigationLink {
                            ExperienceDetailView(
                                event: event,
                                bgColor: bgTeal,
                                nextColor: accentGreen
                            )
                        } label: {
                            miniEventCard(for: event)
                        }
                        .buttonStyle(.plain)
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
    
    private var communitySoundSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Community Join Sound")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black.opacity(0.6))
                
                Text("Record a fun noise or catchphrase. It might play when someone joins an event!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack {
                    Spacer()
                    RecordButtonView(btnPurple: btnPurple) // Pass your custom purple to match theme
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
}


#Preview {
    ProfileView()
        .environmentObject(EventManager())
        .environmentObject(AuthManager())
        .environmentObject(VoiceManager())
}
