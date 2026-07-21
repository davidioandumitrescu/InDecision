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
    @Published var joinedEventIDs: Set<UUID> = []
    @Published var errorMessage = ""
    
    @Published var selectedTab: Int = 0
    @Published var formResetTrigger = UUID()
    @Published var hasUnsavedChanges: Bool = false
    
    // MARK: - Load Events
    
    func loadEvents() async {
        do {
            var fetchedEvents: [DetailedEvent] = try await SupabaseManager.shared.client
                .from("events")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            for index in fetchedEvents.indices {
                // Get save count
                let saveCount: Int = try await SupabaseManager.shared.client
                    .rpc(
                        "get_event_save_count",
                        params: [
                            "event_uuid": fetchedEvents[index].id.uuidString
                        ]
                    )
                    .execute()
                    .value

                fetchedEvents[index].likeCount = saveCount

                // Get joined event count
                let joinCount: Int = try await SupabaseManager.shared.client
                    .rpc(
                        "get_joined_event_count",
                        params: [
                            "event_uuid": fetchedEvents[index].id.uuidString
                        ]
                    )
                    .execute()
                    .value

                fetchedEvents[index].joinedCount = joinCount
            }

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
            //automatically save and join the event you created
            let joinEvent = JoinedEvent(userID: event.created_by, eventID: event.id)
            
            try await SupabaseManager.shared.client
                .from("joined_events")
                .insert(joinEvent)
                .execute()
            
            // Add it to our local Set so the button instantly says "You are going"
            //joinedEventIDs.insert(event.id)
            
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

            errorMessage = ""
            
            if let index = events.firstIndex(where: { $0.id == eventId }) {
                events[index].likeCount += 1
                try await SupabaseManager.shared.client
                    .from("events")
                    .update(["like_count": events[index].likeCount])
                    .eq("id", value: eventId.uuidString)
                    .execute()
            }
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
            
            // Bump the joined counter down
            if let index = events.firstIndex(where: { $0.id == eventId }) {
                events[index].likeCount = max(0, events[index].likeCount - 1)
                try await SupabaseManager.shared.client
                    .from("events")
                    .update(["like_count": events[index].likeCount])
                    .eq("id", value: eventId.uuidString)
                    .execute()
            }
            
            savedEventIDs.remove(eventId)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to unsave event:", error)
        }
    }
    
    
    func loadJoinedEvents(for userID: UUID?) async {
            guard let userID else {
                joinedEventIDs = []
                return
            }

            do {
                let joinedEvents: [JoinedEvent] = try await SupabaseManager.shared.client
                    .from("joined_events")
                    .select()
                    .eq("user_id", value: userID.uuidString)
                    .execute()
                    .value

                joinedEventIDs = Set(joinedEvents.map(\.eventID))
                errorMessage = ""
            } catch {
                errorMessage = error.localizedDescription
                print("❌ Failed to load joined events:", error)
            }
        }

        func toggleJoin(for eventId: UUID, userID: UUID?) async {
            guard let userID else {
                errorMessage = "You need to sign in before joining events."
                return
            }

            if joinedEventIDs.contains(eventId) {
                await leaveEvent(eventId, userID: userID)
            } else {
                await joinEvent(eventId, userID: userID)
            }
        }
        
        func isJoined(eventId: UUID) -> Bool {
            joinedEventIDs.contains(eventId)
        }

        private func joinEvent(_ eventId: UUID, userID: UUID) async {
            let joinedEvent = JoinedEvent(userID: userID, eventID: eventId)

            do {
                try await SupabaseManager.shared.client
                    .from("joined_events")
                    .insert(joinedEvent)
                    .execute()

                joinedEventIDs.insert(eventId)
                
                
                
                // Bump the joined counter up
                if let index = events.firstIndex(where: { $0.id == eventId }) {
                    events[index].joinedCount += 1
                    try await SupabaseManager.shared.client
                        .from("events")
                        .update(["joined_count": events[index].joinedCount])
                        .eq("id", value: eventId.uuidString)
                        .execute()
                }
                
                errorMessage = ""
            } catch {
                errorMessage = error.localizedDescription
                print("❌ Failed to join event:", error)
            }
        }

        private func leaveEvent(_ eventId: UUID, userID: UUID) async {
            do {
                try await SupabaseManager.shared.client
                    .from("joined_events")
                    .delete()
                    .eq("user_id", value: userID.uuidString)
                    .eq("event_id", value: eventId.uuidString)
                    .execute()

                joinedEventIDs.remove(eventId)
                
                // Bump the joined counter down
                if let index = events.firstIndex(where: { $0.id == eventId }) {
                    events[index].joinedCount = max(0, events[index].joinedCount - 1)
                    try await SupabaseManager.shared.client
                        .from("events")
                        .update(["joined_count": events[index].joinedCount])
                        .eq("id", value: eventId.uuidString)
                        .execute()
                }
                
                errorMessage = ""
            } catch {
                errorMessage = error.localizedDescription
                print("❌ Failed to leave event:", error)
            }
        }
    
    func updateEvent(_ event: DetailedEvent) async -> Bool {
            do {
                try await SupabaseManager.shared.client
                    .from("events")
                    .update(event) // Supabase will automatically map this to the row with the matching ID
                    .eq("id", value: event.id.uuidString)
                    .execute()
                
                // Instantly update our local array so the UI changes without needing to reload
                if let index = events.firstIndex(where: { $0.id == event.id }) {
                    events[index] = event
                }
                
                errorMessage = ""
                print("✅ Event updated")
                return true
                
            } catch {
                errorMessage = error.localizedDescription
                print("❌ Failed to update event:", error)
                return false
            }
        }
        
        func deleteEvent(eventID: UUID) async {
            do {
                try await SupabaseManager.shared.client
                    .from("events")
                    .delete()
                    .eq("id", value: eventID.uuidString)
                    .execute()
                
                // Instantly remove it from our local arrays so it vanishes from the UI
                events.removeAll(where: { $0.id == eventID })
                savedEventIDs.remove(eventID)
                joinedEventIDs.remove(eventID)
                
                errorMessage = ""
                print("✅ Event deleted")
                
            } catch {
                errorMessage = error.localizedDescription
                print("❌ Failed to delete event:", error)
            }
        }
    
    func getAttendees(for eventID: UUID) async -> [Profile] {
            do {
                // 1. Get all the joined records for this specific event
                let joinedEvents: [JoinedEvent] = try await SupabaseManager.shared.client
                    .from("joined_events")
                    .select()
                    .eq("event_id", value: eventID.uuidString)
                    .execute()
                    .value
                
                // Extract just the user IDs
                let userIDs = joinedEvents.map(\.userID.uuidString)
                
                // If no one is joined (shouldn't happen since host auto-joins, but good safety check), return empty
                guard !userIDs.isEmpty else { return [] }
                
                // 2. Fetch the actual user profiles that match those IDs
                let profiles: [Profile] = try await SupabaseManager.shared.client
                    .from("profiles")
                    .select()
                    .in("id", values: userIDs)
                    .execute()
                    .value
                
                return profiles
                
            } catch {
                print("❌ Failed to fetch attendees:", error.localizedDescription)
                return []
            }
        }
    
}
