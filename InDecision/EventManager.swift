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
            //add the host as an atendee if this works
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
    
    func loadSavedEvents(for userID: UUID?) async {
        guard let userID else {
            savedEventIDs = []
            return
        }

        do {
            let savedEvents: [SavedEvent] = try await SupabaseManager.shared.client
                .from("saved_events")
                .select()
                .eq("user_id", value: userID.uuidString)
                .execute()
                .value

            savedEventIDs = Set(savedEvents.map(\.eventID))
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load saved events:", error)
        }
    }

    func toggleSave(for eventId: UUID, userID: UUID?) async {
        guard let userID else {
            errorMessage = "You need to sign in before saving events."
            return
        }

        if savedEventIDs.contains(eventId) {
            await unsaveEvent(eventId, userID: userID)
        } else {
            await saveEvent(eventId, userID: userID)
        }
    }

    func clearSavedEvents() {
        savedEventIDs = []
    }
    
    func isSaved(eventId: UUID) -> Bool {
        savedEventIDs.contains(eventId)
    }

    private func saveEvent(_ eventId: UUID, userID: UUID) async {
        let savedEvent = SavedEvent(userID: userID, eventID: eventId)

        do {
            try await SupabaseManager.shared.client
                .from("saved_events")
                .insert(savedEvent)
                .execute()

            savedEventIDs.insert(eventId)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to save event:", error)
        }
    }

    private func unsaveEvent(_ eventId: UUID, userID: UUID) async {
        do {
            try await SupabaseManager.shared.client
                .from("saved_events")
                .delete()
                .eq("user_id", value: userID.uuidString)
                .eq("event_id", value: eventId.uuidString)
                .execute()

            savedEventIDs.remove(eventId)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to unsave event:", error)
        }
    }
}
