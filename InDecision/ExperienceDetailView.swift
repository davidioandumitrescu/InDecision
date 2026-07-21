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
    
    var body: some View {
        ZStack {
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
            
            // 2. Core Content Layer
            VStack(alignment: .leading, spacing: 24) {
                headerBar
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        Text("\(Int(currentEvent.maxPeople) - currentEvent.joinedCount) more people to reach goal!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.top, 10)
                        
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
                }
            }
            .padding(.horizontal, 24)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            // Placeholder: When you implement your DB fetch, uncomment this:
            // attendees = await eventManager.getAttendees(for: event.id)
            isLoadingAttendees = false
        }
    }
    
    // MARK: - Subsections
    
    private var headerBar: some View {
            HStack {
                // 1. The Custom Back Button
                Button(action: {
                    dismiss() // This safely takes you back to the list!
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                    }
                    .foregroundColor(.white)
                }
                
                Spacer()
                
                // 2. The Profile Button
                NavigationLink(destination: ProfileDestinationView()) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 10)
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
        HStack(spacing: 10) {
            if isLoadingAttendees {
                ProgressView().tint(.white)
            } else {
                // Placeholder loop - will show real data once eventManager.getAttendees is ready
                ForEach(attendees) { user in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 54, height: 54)
                }
            }
        }
    }
    
    private var actionButtonsArea: some View {
        VStack(spacing: 12) {
            Button(action: {
                    Task {
                        await eventManager.toggleJoin(for: event.id, userID: authManager.userID)
                    }
            }) {
                HStack {
                    Image(systemName: isJoined ? "checkmark.circle.fill" : "checkmark.circle")
                    Text(isJoined ? "You are going" : "Yes, I'm in!")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(isJoined ? buttonPurple : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(isJoined ? Color.white : buttonPurple)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            Button(action: {
                Task {
                    await eventManager.toggleSave(for: event.id, userID: authManager.userID)
                }
            }) {
                Label(isSaved ? "Saved" : "Save for later", systemImage: isSaved ? "heart.fill" : "heart")
                    .font(Font.body.bold())
                    .foregroundColor(buttonPurple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: buttonPurple.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 50)
        }
    }
}
