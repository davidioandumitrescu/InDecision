//
//  ExperienceCreateView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI
import Supabase

struct ExperienceCreateView: View {
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Form State
    @State private var hostName: String = ""
    @State private var location: String = ""
    @State private var experienceType: String = "Explore"
    
    @State private var activity: String = ""
    @State private var connectionTarget: String = ""
    @State private var minPeople: Int = 2
    @State private var maxPeople: Int = 5
    @State private var time: String = ""
    
    // Using a simple comma-separated string for quick scaffolding
    @State private var daysString: String = ""
    @State private var isSolid: Bool = false
    
    let types = ["Teach", "Demonstrate", "StoryTell", "Build", "Mentor", "Explore", "Discuss", "Practice"]
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Host Info
                Section(header: Text("Host Information")) {
                    TextField("Your Name", text: $hostName)
                    TextField("Location", text: $location)
                    
                    Picker("Experience Type", selection: $experienceType) {
                        ForEach(types, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }
                
                // MARK: - Event Details
                Section(header: Text("Event Details")) {
                    TextField("Activity (e.g., rock climbing)", text: $activity)
                    TextField("Looking for (e.g., adventurers)", text: $connectionTarget)
                    TextField("Time (e.g., 5:00 PM)", text: $time)
                    
                    // Quick way to get an array of strings without building a custom multi-select yet
                    TextField("Days (comma separated)", text: $daysString)
                }
                
                // MARK: - Capacity & Status
                Section(header: Text("Settings")) {
                    Stepper("Min People: \(minPeople)", value: $minPeople, in: 1...20)
                    Stepper("Max People: \(maxPeople)", value: $maxPeople, in: minPeople...50)
                    
                    Toggle("Is this a Solid event?", isOn: $isSolid)
                        .tint(.green)
                }
            }
            .navigationTitle("New Experience")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createEvent()
                    }
                    .bold()
                }
            }
        }
    }
    
    // MARK: - Action
    private func createEvent() {
        // Convert the comma-separated string into an array of strings
        let parsedDays = daysString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let newEvent = DetailedEvent(
            hostName: hostName.isEmpty ? "Unknown" : hostName,
            location: location.isEmpty ? "TBD" : location,
            experienceType: experienceType,
            activity: activity.isEmpty ? "do something" : activity,
            connectionTarget: connectionTarget.isEmpty ? "people" : connectionTarget,
            minPeople: minPeople,
            maxPeople: maxPeople,
            selectedDays: parsedDays.isEmpty ? ["Anytime"] : parsedDays,
            time: time.isEmpty ? "Flexible" : time,
            likeCount: 0, // Starts at 0
            joinedCount: 1, // Usually the host counts as 1
            isSolid: isSolid
        )
        
        // For now, we just print it. Later, you'll pass this to your database or EventManager!
        print("Created new event: \(newEvent.generatedTitle)")
        
        dismiss()
    }
}


private func addEvent(event: DetailedEvent) async {
    do {
        try await SupabaseManager.shared.client
            .from("events")
            .insert(event)
            .execute()

        print("✅ Event uploaded")

    } catch {
        print("❌ Upload failed:", error)
    }
}

