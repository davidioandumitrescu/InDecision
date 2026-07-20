//
//  ExperienceCreateView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//
/**

import SwiftUI
import Supabase
import PhotosUI
import UIKit

struct ExperienceCreateView1: View {
    
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var authManager: AuthManager
    
    // Form State
    
    @State  var activity: String = ""
    @State  var connectionTarget: String = ""
    @State  var minPeople: Int = 0
    @State  var maxPeople: Int = 0
    @State  var selectedDays: [String] = []
    @State  var time: String = ""
    @State  var isSolid: Bool = false
    @State  var location: String = ""
    @State  var experienceType: String = ""
    @State  var description: String = ""
    
    @State  var showValidationError = false
    @State  var validationMessage = ""
    
    let experienceTypes = ["Teach", "Demonstrate", "StoryTell", "Build", "Mentor", "Explore", "Discuss", "Practice"]
    
    var isFormValid: Bool {
        if authManager.userID == nil { return false }
        if activity.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        if description.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        
        if isSolid {
            if location.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        }

        return true
    }

    private func getValidationMessage() -> String {
        var missingFields: [String] = []
        
        if authManager.userID == nil { missingFields.append("Signed-in account") }
        if activity.trimmingCharacters(in: .whitespaces).isEmpty { missingFields.append("Title") }
        if description.trimmingCharacters(in: .whitespaces).isEmpty { missingFields.append("Description") }
        
        if isSolid && location.trimmingCharacters(in: .whitespaces).isEmpty {
            missingFields.append("Location")
        }
        
        return "Please fill out the following required fields: \n\n• " + missingFields.joined(separator: "\n• ")
    }
    
    private func checkUnsavedChanges() {
        let isDirty = !activity.isEmpty || !location.isEmpty || !description.isEmpty || maxPeople > 0
        if eventManager.hasUnsavedChanges != isDirty {
            eventManager.hasUnsavedChanges = isDirty
        }
    }
    
    private func resetForm() {
        activity = ""
        isSolid = true
        location = ""
        selectedDays = []
        time = ""
        description = ""
        experienceType = "Teach"
        minPeople = 0
        maxPeople = 5
        eventManager.hasUnsavedChanges = false
    }
    
    var body: some View {
        @State  var minValue = 20.0
        @State  var maxValue = 80.0

        ZStack{
            Form {
                /**Section {
                    Picker("Status", selection: $isSolid) {
                        Text("Proposed").tag(false)
                        Text("Solid").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: isSolid) { checkUnsavedChanges() }
                }**/
                
                Section(header: Text("What are you looking to do?")) {
                    TextField("Title (Required)", text: $activity)
                        .onChange(of: activity) { checkUnsavedChanges() }

                }
                Section(header: Text("Who are you looking to connect with?")) {
                    TextField("Location (Required)", text: $location)
                        .onChange(of: location) { checkUnsavedChanges() }
                    
                }
                
                Section(header: Text("With how many people?")){
                    RangeSlider(
                        lowerValue: $minValue,
                        upperValue: $maxValue,
                        bounds: 0...100
                    )
                    .padding()

                }
                
                
                Section(header: Text("Experience Type")) {
                    Picker("Type", selection: $experienceType) {
                        ForEach(experienceTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }.pickerStyle(.menu)
                }
                
                Section(header: Text("Description (Required)")) {
                    TextEditor(text: $description).frame(height: 80)
                        .onChange(of: description) { checkUnsavedChanges() }
                }
                
                
            }
            .scrollContentBackground(.hidden)
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
        .background(Color.white)
        
    }
    
    private func saveEvent() async {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        //let startDString = formatter.string(from: startDate)
        //let endDString = formatter.string(from: endDate)
        
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        //let startTString = formatter.string(from: startTime)
        //let endTString = formatter.string(from: endTime)
        
        guard let creatorID = authManager.userID else {
            validationMessage = "You need to sign in before creating an event."
            showValidationError = true
            return
        }

        if isFormValid {
            Task {
                await saveEvent()
            }
        } else {
            validationMessage = getValidationMessage()
            showValidationError = true
        }
    }

    private func toggleDay(_ day: String) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }

        checkUnsavedChanges()
    }

    private var formattedSelectedDays: String {
        let sortedDays = selectedDays.sorted {
            dayIndex($0) < dayIndex($1)
        }

        guard !sortedDays.isEmpty else {
            return "any day"
        }

        if sortedDays.count == 1 {
            return fullDayName(sortedDays[0])
        }
        
        //let finalDate = isSolid ? startDString : "\(startDString) - \(endDString)"
        //let finalTime = isSolid ? startTString : "\(startTString) - \(endTString)"
        let hostName = authManager.profile?.full_name ?? authManager.profile?.username ?? "Me"
        //let contactEmail = contactInfo.isEmpty ? authManager.userEmail ?? "" : contactInfo
        
        let newEvent = DetailedEvent(location: location, experienceType: experienceType, activity: activity, connectionTarget: connectionTarget, minPeople: minPeople, maxPeople: maxPeople, selectedDays: [], time: time, likeCount: 0, joinedCount: 0)
        
        return "multiple days"
    }

    private func dayIndex(_ day: String) -> Int {
        weekDays.firstIndex(of: day)
        ?? weekDays.count
    }

    private func fullDayName(
        _ abbreviatedDay: String
    ) -> String {
        switch abbreviatedDay {
        case "Mon":
            return "monday"
        case "Tue":
            return "tuesday"
        case "Wed":
            return "wednesday"
        case "Thu":
            return "thursday"
        case "Fri":
            return "friday"
        case "Sat":
            return "saturday"
        case "Sun":
            return "sunday"
        default:
            return abbreviatedDay
        }
    }

    // MARK: - Unsaved Changes

    private func checkUnsavedChanges() {
        let hasTextChanges =
            !title.isEmpty
            || !audience.isEmpty
            || !location.isEmpty
            || !description.isEmpty
            || !contactInfo.isEmpty

        let hasOtherChanges =
            capacity != 5
            || selectedDays != ["Mon", "Tue"]
            || selectedUIImage != nil

        let isDirty =
            hasTextChanges
            || hasOtherChanges

        if eventManager.hasUnsavedChanges != isDirty {
            eventManager.hasUnsavedChanges = isDirty
        }
    }

    private func resetForm() {
        title = ""
        audience = ""
        location = ""
        description = ""
        contactInfo = ""

        selectedExperience = "Explore"
        capacity = 5
        startTime = Date()
        selectedDays = ["Mon", "Tue"]

        selectedPhotoItem = nil
        selectedImageData = nil
        selectedUIImage = nil

        uploadErrorMessage = nil
        isUploading = false

        eventManager.hasUnsavedChanges = false
    }

    // MARK: - Save Event

    @MainActor
    private func saveEvent() async {
        isUploading = true
        uploadErrorMessage = nil

        defer {
            isUploading = false
        }

        do {
            let imageURL = try await uploadEventImage()

            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short

            let timeString = timeFormatter.string(
                from: startTime
            )

            let trimmedTitle = title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            let trimmedAudience =
                audience.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let trimmedDescription =
                description.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let trimmedContact =
                contactInfo.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let hostName =
                authManager.profile?.full_name
                ?? authManager.profile?.username
                ?? "Guest"

            /*
             Audience is not currently a separate
             DetailedEvent or database field, so it
             is included in the description.
             */
            let savedDescription = """
            Looking to connect with: \(trimmedAudience)

            \(trimmedDescription)
            """

            let newEvent = DetailedEvent(
                createdBy: authManager.userID,
                title: trimmedTitle,
                status: .proposed,
                hostName: hostName,
                location: location.isEmpty
                    ? "TBD"
                    : location,
                date: formattedSelectedDays,
                time: timeString,
                description: savedDescription,
                experienceType: selectedExperience,
                capacity: capacity,
                contactEmail: trimmedContact,
                imgUrl: imageURL
            )

            print(
                "🖼️ New event image URL:",
                newEvent.imgUrl ?? "nil"
            )

            let didCreateEvent =
                await eventManager.createEvent(
                    newEvent
                )

            if didCreateEvent {
                eventManager.formResetTrigger = UUID()
                eventManager.selectedTab = 0
            } else {
                validationMessage =
                    eventManager.errorMessage.isEmpty
                    ? "Event could not be created."
                    : eventManager.errorMessage

                showValidationError = true
            }

        } catch {
            let errorMessage =
                "Image upload failed: \(error.localizedDescription)"

            uploadErrorMessage = errorMessage
            validationMessage = errorMessage
            showValidationError = true

            print(
                "❌ Image upload failed:",
                error
            )
        }
    }

#Preview {
    ExperienceCreateView()
        .environmentObject(EventManager())
        .environmentObject(AuthManager())
}

**/
