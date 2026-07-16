//
//  EventManager.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import Foundation
import SwiftUI
import Combine

class EventManager: ObservableObject {
    
    @Published var events: [DetailedEvent] = []
    @Published var savedEventIDs: Set<String> = []
    
    @Published var selectedTab: Int = 0
    @Published var formResetTrigger = UUID()
    @Published var hasUnsavedChanges: Bool = false
    
    init() {
        loadDummyData()
    }
    
    func createEvent(_ event: DetailedEvent) {
        events.append(event)
    }
    
    func toggleSave(for eventId: String) {
        if savedEventIDs.contains(eventId) {
            savedEventIDs.remove(eventId)
        } else {
            savedEventIDs.insert(eventId)
        }
    }
    
    func isSaved(eventId: String) -> Bool {
        return savedEventIDs.contains(eventId)
    }
    
    private func loadDummyData() {
            events = [
                DetailedEvent(title: "Learn Baking", status: .solid, hostName: "Georgia", location: "Armadale", date: "Apr 1, 2025", time: "2:00 PM", description: "Bake cinnamon scrolls with friends. All ingredients provided!", experienceType: "Teach", capacity: 10, contactEmail: "georgia@email.com"),
                
                DetailedEvent(title: "Learn to Juggle", status: .proposed, hostName: "David", location: "Hyde Park", date: "TBD", time: "TBD", description: "Looking to practice juggling. I have extra bean bags, let's find a time that works.", experienceType: "Practice", capacity: 20, contactEmail: "david@email.com"),
                
                DetailedEvent(title: "Figma Deep Dive", status: .solid, hostName: "Alice", location: "Perth CBD", date: "May 15, 2025", time: "6:00 PM", description: "Advanced prototyping and auto-layout workshop for local designers.", experienceType: "Demonstrate", capacity: 15, contactEmail: "alice@design.com"),
                
                DetailedEvent(title: "Hip Hop Dance Basics", status: .proposed, hostName: "Marcus", location: "TBD - Northbridge", date: "Weekends", time: "Mornings", description: "Let's rent a studio and learn some basic hip hop grooves together.", experienceType: "Experience", capacity: 30, contactEmail: "marcus@dance.com"),
                
                DetailedEvent(title: "Pitch Deck Feedback", status: .solid, hostName: "Sarah", location: "WeWork", date: "Jun 10, 2025", time: "10:00 AM", description: "Bring your startup pitch decks and let's review them as a group.", experienceType: "Discuss", capacity: 8, contactEmail: "sarah@startup.io"),
                
                DetailedEvent(title: "Community Garden Build", status: .proposed, hostName: "Leo", location: "Fremantle", date: "Next Month", time: "TBD", description: "Need hands to help build raised planter beds for the neighborhood.", experienceType: "Build", capacity: 25, contactEmail: "leo@green.org")
            ]
            
            if events.count >= 4 {
                savedEventIDs = [events[0].id, events[2].id, events[3].id]
            }
        }
}
