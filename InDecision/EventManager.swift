//
//  EventManager.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class EventManager: ObservableObject {
    
    @Published var events: [DetailedEvent] = []
    @Published var savedEventIDs: Set<UUID> = []
    
    @Published var selectedTab: Int = 0
    @Published var formResetTrigger = UUID()
    @Published var hasUnsavedChanges: Bool = false
    
    // MARK: - Load Events
    
    func loadEvents() async {
        do {
            let fetchedEvents: [DetailedEvent] = try await SupabaseManager.shared.client
                .from("events")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.events = fetchedEvents
            
            print("✅ Loaded \(fetchedEvents.count) events")
            
        } catch {
            print("❌ Failed to load events:", error)
        }
    }
    
    
    // MARK: - Create Event
    
    func createEvent(_ event: DetailedEvent) async {
        do {
            try await SupabaseManager.shared.client
                .from("events")
                .insert(event)
                .execute()
            
            print("✅ Event created")
            
            await loadEvents()
            
        } catch {
            print("❌ Failed to create event:", error)
        }
    }
    
    
    // MARK: - Saved Events
    
    func toggleSave(for eventId: UUID) {
        if savedEventIDs.contains(eventId) {
            savedEventIDs.remove(eventId)
        } else {
            savedEventIDs.insert(eventId)
        }
    }
    
    
    func isSaved(eventId: UUID) -> Bool {
        savedEventIDs.contains(eventId)
    }
}
