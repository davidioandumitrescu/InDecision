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
    private let bgTeal = Color("AppSurface")
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
                        VStack(alignment: .leading, spacing: 24) {
                            
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
    
    // MARK: - Subsectionsß
    
    private var headerBar: some View {
        HStack {
            Text("My Experience")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            NavigationLink(destination: ProfileDestinationView()) {
                AvatarView(userID: authManager.userID, size: 50)
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
        VStack(alignment: .leading, spacing: 12) {
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

    private var activityTitle: String {
        let trimmedActivity = event.activity.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedActivity.isEmpty ? "Untitled Experience" : trimmedActivity.localizedCapitalized
    }

    private var primaryDay: String {
        guard let firstDay = event.selectedDays.first else { return "ANY" }
        return String(firstDay.prefix(3)).uppercased()
    }

    private var additionalDayText: String {
        let additionalDayCount = max(event.selectedDays.count - 1, 0)
        return additionalDayCount == 0 ? "DAY" : "+\(additionalDayCount) DAY"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(activityTitle)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black.opacity(0.85))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.black.opacity(0.35))
                    Text(event.time.formatted(date: .omitted, time: .shortened))
                        .foregroundColor(.black.opacity(0.55))

                    Image(systemName: "person.2.fill")
                        .foregroundColor(.black.opacity(0.35))
                        .padding(.leading, 4)
                    Text("\(event.joinedCount)/\(Int(event.maxPeople))")
                        .foregroundColor(.black.opacity(0.55))
                }
                .font(.subheadline.weight(.semibold))
            }

            Spacer(minLength: 8)

            VStack(spacing: 2) {
                Text(primaryDay)
                    .font(.system(size: 16, weight: .bold))
                Text(additionalDayText)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(.black.opacity(0.55))
            .frame(width: 64, height: 60)
            .background(Color.black.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}


#Preview {
    ExperienceSavedView()
        .environmentObject(EventManager())
        .environmentObject(AuthManager())
}
