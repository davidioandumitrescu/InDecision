//
//  ExperienceSavedView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI

struct ExperienceSavedView: View {
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var authManager: AuthManager
    
    // Theme Colors matching the rest of the app
    private let bgTeal = Color.mint
    private let accentGreen = Color.green
    
    // Computed Data
    var savedEvents: [DetailedEvent] {
        eventManager.events.filter { eventManager.savedEventIDs.contains($0.id) }
    }
    
    var joinedEvents: [DetailedEvent] {
        eventManager.events.filter { eventManager.joinedEventIDs.contains($0.id) }
    }
    
    var body: some View {
        ZStack {
            // 1. Background Layers
            bgTeal.ignoresSafeArea()
            
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
            VStack(alignment: .leading, spacing: 16) {
                headerBar
                
                if savedEvents.isEmpty && joinedEvents.isEmpty {
                    Spacer()
                    emptyStateView
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 30) {
                            
                            // Joined Events Section
                            if !joinedEvents.isEmpty {
                                eventSection(title: "I'm Going", events: joinedEvents)
                            }
                            
                            // Saved Events Section
                            if !savedEvents.isEmpty {
                                eventSection(title: "Saved for Later", events: savedEvents)
                            }
                            
                            Spacer(minLength: 80) // Breathing room for the bottom tab bar
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            // Ensure data is loaded
            if eventManager.events.isEmpty {
                await eventManager.loadEvents()
            }
            await eventManager.loadSavedEvents(for: authManager.userID)
            await eventManager.loadJoinedEvents(for: authManager.userID)
        }
    }
    
    // MARK: - Subsections
    
    private var headerBar: some View {
        HStack {
            Text("My Experience")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            NavigationLink(destination: ProfileDestinationView()) {
                AvatarView(userID: authManager.userID)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No events yet!")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("Events you save or join will appear here.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func eventSection(title: String, events: [DetailedEvent]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            ForEach(events) { event in
                // The Navigation Link wraps the entire card
                NavigationLink(destination: ExperienceDetailView(event: event, bgColor: bgTeal, nextColor: accentGreen)) {
                    EventCard(event: event)
                }
                .buttonStyle(PlainButtonStyle()) // Prevents SwiftUI from overriding our text colors
            }
        }
    }
}

// MARK: - Reusable Event Card
struct EventCard: View {
    let event: DetailedEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Uses the awesome stylized text from your model!
            event.stylizedPreview
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.white.opacity(0.7))
                    Text(event.location.isEmpty ? "Undecided" : event.location)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.white.opacity(0.7))
                    Text(event.time.formatted(date: .omitted, time: .shortened))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .font(.subheadline)
            .fontWeight(.medium)
        }
        .padding(20)
        // Uses a nice dark semi-transparent glass effect that looks great on the teal
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
