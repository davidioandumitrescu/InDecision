//
//  ExperienceCreateView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI
import Supabase
import PhotosUI
import UIKit

struct ExperienceCreateView: View {
    
    @EnvironmentObject var eventManager: EventManager
    
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
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedUIImage: UIImage?

    @State private var isUploading = false
    @State private var uploadErrorMessage: String?
    
    @State private var showValidationError = false
    @State private var validationMessage = ""
    
    let experienceTypes = ["Teach", "Demonstrate", "StoryTell", "Build", "Mentor", "Explore", "Discuss", "Practice"]
    
    var isFormValid: Bool {
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
        
        selectedPhotoItem = nil
        selectedImageData = nil
        selectedUIImage = nil
        uploadErrorMessage = nil
        
        eventManager.hasUnsavedChanges = false
    }
    
    var body: some View {
        Form {
            Section(header: Text("Event Image")) {
                if let selectedUIImage {
                    Image(uiImage: selectedUIImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .clipped()
                    
                    Button(role: .destructive) {
                        selectedPhotoItem = nil
                        selectedImageData = nil
                        self.selectedUIImage = nil
                        checkUnsavedChanges()
                    } label: {
                        Label("Remove Image", systemImage: "trash")
                    }
                }
                
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label(
                        selectedUIImage == nil ? "Select Image" : "Change Image",
                        systemImage: "photo"
                    )
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    guard let newItem else { return }

                    Task {
                        await loadSelectedImage(from: newItem)
                    }
                }
            }
            
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
                Button {
                    if isFormValid {
                        Task {
                            await saveEvent()
                        }
                    } else {
                        validationMessage = getValidationMessage()
                        showValidationError = true
                    }
                } label: {
                    if isUploading {
                        ProgressView()
                    } else {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.bold))
                    }
                }
                .foregroundColor(.green)
                .disabled(isUploading)
            }
        }
    }
    
    private func saveEvent() async {
        do {
            let imageURL = try await uploadEventImage()
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let startDString = formatter.string(from: startDate)
            let endDString = formatter.string(from: endDate)
            
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            let startTString = formatter.string(from: startTime)
            let endTString = formatter.string(from: endTime)
            
            let finalDate = isSolid ? startDString : "\(startDString) - \(endDString)"
            let finalTime = isSolid ? startTString : "\(startTString) - \(endTString)"
            
            let newEvent = DetailedEvent(
                title: title,
                status: isSolid ? .solid : .proposed,
                hostName: "Me",
                location: location.isEmpty ? "TBD" : location,
                date: finalDate,
                time: finalTime,
                description: description,
                experienceType: selectedExperience,
                capacity: capacity,
                contactEmail: contactInfo,
                imgUrl: imageURL

            )
            
            await eventManager.createEvent(newEvent)
            eventManager.formResetTrigger = UUID()
            eventManager.selectedTab = 0
            
            
        } catch {
            uploadErrorMessage =
                "Image upload failed: \(error.localizedDescription)"

            print("❌ Image upload failed:", error)
        }
       
    }
    
    private func loadSelectedImage(from item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                uploadErrorMessage = "The selected image could not be loaded."
                return
            }

            guard let compressedData = image.jpegData(
                compressionQuality: 0.75
            ) else {
                uploadErrorMessage = "The selected image could not be processed."
                return
            }

            selectedUIImage = image
            selectedImageData = compressedData
            checkUnsavedChanges()

        } catch {
            uploadErrorMessage =
                "Failed to load image: \(error.localizedDescription)"
        }
    }
    
    private func uploadEventImage() async throws -> String? {
        guard let selectedImageData else {
            return nil
        }
        let bucketName = "imgUrl"
        let fileName = "\(UUID().uuidString).jpg"
        let filePath = "events/\(fileName)"

        try await SupabaseManager.shared.client.storage
            .from(bucketName)
            .upload(
                filePath,
                data: selectedImageData,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: "image/jpeg",
                    upsert: false
                )
            )

        let publicURL = try SupabaseManager.shared.client.storage
            .from(bucketName)
            .getPublicURL(path: filePath)

        return publicURL.absoluteString

    }
        
}


//private func addEvent(event: DetailedEvent) async {
//    do {
//        try await SupabaseManager.shared.client
//            .from("events")
//            .insert(event)
//            .execute()
//
//        print("✅ Event uploaded")
//
//    } catch {
//        print("❌ Upload failed:", error)
//    }
//}

