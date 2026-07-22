//
//  ExperienceDetailView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI

struct ExperienceDetailView: View {

    let event: DetailedEvent
    
    // Dependencies
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showDeleteAlert = false
    @State private var showEditSheet = false
    
    // UI State
    @State private var attendees: [Profile] = []
    @State private var isLoadingAttendees: Bool = true
    
    // Card Pop-up State
    @State private var selectedCardInfo: AttendeeCardInfo?
    
    // Colors passed from list view
    var bgColor: Color
    var nextColor: Color
    
    // Theme Constants
    private let buttonPurple = Color(red: 0.45, green: 0.35, blue: 0.95)
    
    var isJoined: Bool {
        eventManager.joinedEventIDs.contains(event.id)
    }
    var isSaved: Bool {
        eventManager.savedEventIDs.contains(event.id)
    }
    
    var currentEvent: DetailedEvent {
        eventManager.events.first(where: { $0.id == event.id }) ?? event
    }
    
    var sortedAttendees: [Profile] {
        attendees.sorted { (user1, user2) in
            // If user1 is the host, they go first
            if user1.id == currentEvent.created_by { return true }
            // If user2 is the host, they go first
            if user2.id == currentEvent.created_by { return false }
            // Otherwise, sort alphabetically
            return (user1.full_name ?? user1.username) < (user2.full_name ?? user2.username)
        }
    }
    
    var body: some View {
            ZStack(alignment: .top) {
                // 1. Background Layers
                bgColor.ignoresSafeArea()
                 
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 0) {
                            nextColor.frame(width: 125, height: 60)
                            nextColor.frame(width: 250, height: 60)
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                 
                // 2. Core Content Layer (ScrollView with top padding)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        // Invisible spacer so the header doesn't cover your text
                        Spacer().frame(height: 60)
                        
                        var goal = Int(currentEvent.maxPeople) - currentEvent.joinedCount
                        if (goal > 0) {
                            Text("\(goal) more people to reach goal!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black.opacity(0.6))
                                .padding(.top, 10)
                        } else {
                            Text("Event filled!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black.opacity(0.6))
                                .padding(.top, 10)
                        }
                        
                         
                        event.stylizedPreview
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .lineSpacing(6)
                         
                        tagsSection
                        infoRowsSection
                        socialStatsBar
                        attendeesAvatersSection
                         
                        Spacer(minLength: 40)
                        actionButtonsArea
                    }
                    .padding(.horizontal, 24)
                }
                  
                // 3. Pinned Header Bar at the very top of the ZStack
                headerBar
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .zIndex(10)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedCardInfo) { info in
                ProfileCardSheet(info: info)
                    .presentationDetents([.height(380)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showEditSheet) {
                ExperienceEditView(event: currentEvent)
            }
            .task {
                attendees = await eventManager.getAttendees(for: currentEvent.id)
                isLoadingAttendees = false
            }
        }
    
    // MARK: - Subsections
    
    private var headerBar: some View {
        HStack {
            Button(action: {
                dismiss() // This safely takes you back to the list!
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            Spacer()
            
            if authManager.userID == currentEvent.created_by {
                HStack(spacing: 16) {
                    // Edit Button (Pen Icon)
                    Button(action: {
                        showEditSheet = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white)
                    }
                    
                    // Delete Button (Trash Icon)
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            
            // 2. The Profile Button
            NavigationLink(destination: ProfileDestinationView()) {
                AvatarView(userID: authManager.userID)
            }
        }
        .padding(.top, 10)
        .alert("Delete Event", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await eventManager.deleteEvent(eventID: currentEvent.id)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this event? This action cannot be undone.")
        }
    }
    
    private var tagsSection: some View {
        HStack(spacing: 10) {
            Text(event.isSolid ? "Solid" : "Proposed")
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(event.isSolid ? Color.white.opacity(0.4) : Color.black.opacity(0.3))
                .clipShape(Capsule())
                .foregroundColor(.white)
            
            Text(event.experienceType)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.3))
                .clipShape(Capsule())
                .foregroundColor(.white)
            
        }
        .padding(.top)
    }
    
    private var infoRowsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "location.north.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                Text(event.location.isEmpty ? "Location undecided yet" : event.location)
                    .font(.system(size: 18))
                    .foregroundColor(.black.opacity(0.7))
            }
            HStack(spacing: 10) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                Text(event.time.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 18))
                    .foregroundColor(.black.opacity(0.7))
            }
        }
        .fontWeight(.medium)
    }
    
    private var socialStatsBar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "heart.circle")
                    .foregroundColor(.pink.opacity(0.7))
                    .font(.system(size: 24, weight: .bold))
                Text("\(currentEvent.likeCount)")
                    .foregroundColor(.black.opacity(0.7))
            }
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black.opacity(0.7))
                Text("\(currentEvent.joinedCount)")
                    .foregroundColor(.black.opacity(0.7))
            }
        }
        .font(.subheadline)
        .fontWeight(.bold)
    }
    
    private var attendeesAvatersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who's going?")
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.8))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    if isLoadingAttendees {
                        ProgressView().tint(.white)
                            .padding(.leading, 20)
                    } else {
                        // Loop through our sorted real data!
                        ForEach(sortedAttendees, id: \.id) { user in
                            let isHost = user.id == currentEvent.created_by
                            
                            Button(action: {
                                selectedCardInfo = AttendeeCardInfo(
                                    id: user.id,
                                    name: user.full_name ?? user.username,
                                    email: "No email provided",     // Placeholder
                                    hostedCount: isHost ? 5 : 1,   // Placeholder
                                    interests: user.interests ?? [],
                                    isHost: isHost
                                )
                            }) {
                                VStack(spacing: 6) {
                                    ZStack(alignment: .bottomTrailing) {
                                        // The Gray Circle Placeholder
                                        AvatarView(userID: user.id, size: 60)
                                        
                                        // Verified Badge for Host
                                        if isHost {
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.blue)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .offset(x: 2, y: 2)
                                        }
                                    }
                                    
                                    // Name underneath
                                    Text(user.full_name ?? user.username)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .frame(width: 64)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var actionButtonsArea: some View {
        VStack(spacing: 12) {
            // ----- Join Button -----
            let isFull = currentEvent.joinedCount >= Int(currentEvent.maxPeople)
            let joinDisabled = isFull && !isJoined

            Button(action: {
                Task {
                    await eventManager.toggleJoin(for: event.id, userID: authManager.userID)
                    await refreshAttendees()
                }
            }) {
                HStack {
                    Image(systemName: isJoined ? "checkmark.circle.fill" : "checkmark.circle")
                    Text(joinDisabled ? "Event is full" : (isJoined ? "You are going" : "Yes, I'm in!"))
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(joinDisabled ? .gray : (isJoined ? buttonPurple : .white))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(joinDisabled ? Color.gray.opacity(0.4) : (isJoined ? Color.white : buttonPurple))
                .clipShape(Capsule())
                .shadow(color: joinDisabled ? .clear : .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .disabled(joinDisabled)

            // ----- Save Button (unchanged) -----
            Button(action: {
                Task {
                    await eventManager.toggleSave(for: event.id, userID: authManager.userID)
                }
            }) {
                Label(isSaved ? "Saved" : "Save for later", systemImage: isSaved ? "heart.fill" : "heart")
                    .font(Font.body.bold())
                    .foregroundColor(isSaved ? .white : buttonPurple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(isSaved ? .pink.opacity(0.8) : Color.white)
                    .clipShape(Capsule())
                    .shadow(color: buttonPurple.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Helpers
    
    private func refreshAttendees() async {
        isLoadingAttendees = true
        attendees = await eventManager.getAttendees(for: currentEvent.id)
        isLoadingAttendees = false
    }
}

// MARK: - Popup Card Data & View

struct AttendeeCardInfo: Identifiable {
    let id: UUID
    let name: String
    let email: String
    let hostedCount: Int
    let interests: [String]
    let isHost: Bool
}

struct ProfileCardSheet: View {
    let info: AttendeeCardInfo
    
    // Theme Colors
    private let bgTeal = Color.mint
    private let btnPurple = Color(red: 0.50, green: 0.35, blue: 0.96)
    
    var body: some View {
        VStack(spacing: 20) {
            // Header Image
            ZStack(alignment: .bottomTrailing) {
                AvatarView(userID: info.id, size: 80)
                
                if info.isHost {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .background(btnPurple)
                        .clipShape(Circle())
                        .offset(x: 5, y: 5)
                }
            }
            .padding(.top, 30)
            
            // Name & Role
            VStack(spacing: 4) {
                Text(info.name)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text(info.isHost ? "Event Host" : "Attendee")
                    .font(.subheadline.bold())
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Divider().background(Color.white.opacity(0.3)).padding(.horizontal)
            
            // Stats & Contact
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.white)
                        .frame(width: 24)
                    Text(info.email)
                        .font(.body)
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundColor(.white)
                        .frame(width: 24)
                    Text("\(info.hostedCount) Events Hosted")
                        .font(.body)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
            
            // Interests Tags
            VStack(alignment: .leading, spacing: 12) {
                Text("Interests")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.8))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(info.interests, id: \.self) { interest in
                            Text(interest)
                                .font(.caption.bold())
                                .foregroundColor(btnPurple)
                                .fixedSize()
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .background(bgTeal.ignoresSafeArea())
    }
}
