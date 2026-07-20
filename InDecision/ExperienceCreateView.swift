//
//  ExperienceCreateView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI
import Supabase

struct ExperienceCreateView: View {
    
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var authManager: AuthManager
    
    // Form State
    @State private var title = ""
    @State private var isSolid = true
    @State private var location = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var description = ""
    @State private var contactInfo = ""
    @State private var selectedExperience: String = "Teach"
    @State private var capacity: Double = 0
    
    
    @State private var showValidationError = false
    @State private var validationMessage = ""
    
    let experienceTypes = ["Teach", "Demonstrate", "StoryTell", "Build", "Mentor", "Explore", "Discuss", "Practice"]
    
    var isFormValid: Bool {
        if authManager.userID == nil { return false }
        if title.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        if description.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        
        if isSolid {
            if location.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        } else {
            if contactInfo.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        }
        return true
    }
    
    private func getValidationMessage() -> String {
        var missingFields: [String] = []
        
        if authManager.userID == nil { missingFields.append("Signed-in account") }
        if title.trimmingCharacters(in: .whitespaces).isEmpty { missingFields.append("Title") }
        if description.trimmingCharacters(in: .whitespaces).isEmpty { missingFields.append("Description") }
        
        if isSolid && location.trimmingCharacters(in: .whitespaces).isEmpty {
            missingFields.append("Location")
        }
        if !isSolid && contactInfo.trimmingCharacters(in: .whitespaces).isEmpty {
            missingFields.append("Contact Info")
        }
        
        return "Please fill out the following required fields: \n\n• " + missingFields.joined(separator: "\n• ")
    }
    
    private func checkUnsavedChanges() {
        let isDirty = !title.isEmpty || !location.isEmpty || !description.isEmpty || !contactInfo.isEmpty || capacity > 0
        if eventManager.hasUnsavedChanges != isDirty {
            eventManager.hasUnsavedChanges = isDirty
        }
    }
    
    private func resetForm() {
        title = ""
        isSolid = true
        location = ""
        startDate = Date()
        endDate = Date()
        startTime = Date()
        endTime = Date()
        description = ""
        contactInfo = ""
        selectedExperience = "Teach"
        capacity = 0
        eventManager.hasUnsavedChanges = false
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Status", selection: $isSolid) {
                    Text("Proposed").tag(false)
                    Text("Solid").tag(true)
                }
                .pickerStyle(.segmented)
                .onChange(of: isSolid) { checkUnsavedChanges() }
            }
            
            Section(header: Text("Details")) {
                TextField("Title (Required)", text: $title)
                    .onChange(of: title) { checkUnsavedChanges() }
                
                if isSolid {
                    TextField("Location (Required)", text: $location)
                        .onChange(of: location) { checkUnsavedChanges() }
                    DatePicker("Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("Time", selection: $startTime, displayedComponents: .hourAndMinute)
                } else {
                    TextField("Location (Optional)", text: $location)
                        .onChange(of: location) { checkUnsavedChanges() }
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
            }
            
            Section(header: Text("Experience Type")) {
                Picker("Type", selection: $selectedExperience) {
                    ForEach(experienceTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }.pickerStyle(.menu)
            }
            
            Section(header: Text("Description (Required)")) {
                TextEditor(text: $description).frame(height: 80)
                    .onChange(of: description) { checkUnsavedChanges() }
            }
            
            Section(header: Text(capacity == 0 ? "Capacity: Unlimited" : "Capacity: \(Int(capacity)) people")) {
                Slider(value: $capacity, in: 0...20, step: 1)
                    .onChange(of: capacity) { checkUnsavedChanges() }
            }
            
            Section(header: Text("Contact Info")) {
                TextField(isSolid ? "Email or Phone (Optional)" : "Email or Phone (Required)", text: $contactInfo)
                    .onChange(of: contactInfo) { checkUnsavedChanges() }
            }
        }
        .navigationTitle("Create Proposal")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(eventManager.$formResetTrigger) { _ in
            resetForm()
        }
        .alert("Missing Details", isPresented: $showValidationError) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    eventManager.formResetTrigger = UUID()
                    eventManager.selectedTab = 0
                }) {
                    Image(systemName: "xmark").font(.body.weight(.semibold))
                }
                .foregroundColor(.red)
                .opacity(eventManager.hasUnsavedChanges ? 1 : 0.2)
                //.disabled(!eventManager.hasUnsavedChanges)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    if isFormValid {
                        Task{
                            await saveEvent()

                        }
                    } else {
                        validationMessage = getValidationMessage()
                        showValidationError = true
                    }
                }) {
                    Image(systemName: "checkmark").font(.body.weight(.bold))
                }
                .foregroundColor(.green)
            }
        }
    }
    
    private func saveEvent() async {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let startDString = formatter.string(from: startDate)
        let endDString = formatter.string(from: endDate)
        
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let startTString = formatter.string(from: startTime)
        let endTString = formatter.string(from: endTime)
        
        guard let creatorID = authManager.userID else {
            validationMessage = "You need to sign in before creating an event."
            showValidationError = true
            return
        }
        
        let finalDate = isSolid ? startDString : "\(startDString) - \(endDString)"
        let finalTime = isSolid ? startTString : "\(startTString) - \(endTString)"
        let hostName = authManager.profile?.full_name ?? authManager.profile?.username ?? "Me"
        let contactEmail = contactInfo.isEmpty ? authManager.userEmail ?? "" : contactInfo
        
        let newEvent = DetailedEvent(
            createdBy: creatorID,
            title: title,
            status: isSolid ? .solid : .proposed,
            hostName: hostName,
            location: location.isEmpty ? "TBD" : location,
            date: finalDate,
            time: finalTime,
            description: description,
            experienceType: selectedExperience,
            capacity: capacity,
            contactEmail: contactEmail
        )
        
        let didCreateEvent = await eventManager.createEvent(newEvent)
        if didCreateEvent {
            eventManager.formResetTrigger = UUID()
            eventManager.selectedTab = 0
        } else {
            validationMessage = eventManager.errorMessage.isEmpty ? "Event could not be created." : eventManager.errorMessage
            showValidationError = true
        }
    }
}
