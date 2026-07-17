//
//  EventManager.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import Combine
import Foundation
import Supabase
import SwiftUI

@MainActor
class EventManager: ObservableObject {
    
    @Published var events: [DetailedEvent] = []
    @Published var savedEventIDs: Set<UUID> = []
    @Published var errorMessage = ""
    
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
            errorMessage = ""
            
            print("✅ Loaded \(fetchedEvents.count) events")
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load events:", error)
        }
    }
    
    
    // MARK: - Create Event
    
    @discardableResult
    func createEvent(_ event: DetailedEvent) async -> Bool {
        do {
            try await SupabaseManager.shared.client
                .from("events")
                .insert(event)
                .execute()
            
            errorMessage = ""
            print("✅ Event created")
            
            await loadEvents()
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to create event:", error)
            return false
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
