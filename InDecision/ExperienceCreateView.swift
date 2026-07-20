//
//  ExperienceCreateView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//  Updated by Lisa on 20/7/2026.

import SwiftUI
import Supabase
import PhotosUI
import UIKit

struct ExperienceCreateView: View {

    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var authManager: AuthManager

    // MARK: - Form State

    @State private var title = ""
    @State private var audience = ""
    @State private var location = ""
    @State private var description = ""
    @State private var contactInfo = ""

    @State private var selectedExperience = "Explore"
    @State private var capacity: Double = 5
    @State private var startTime = Date()

    @State private var selectedDays: Set<String> = [
        "Mon",
        "Tue"
    ]

    // MARK: - Image State

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedUIImage: UIImage?

    // MARK: - UI State

    @State private var isUploading = false
    @State private var uploadErrorMessage: String?

    @State private var showValidationError = false
    @State private var validationMessage = ""

    private let weekDays = [
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
        "Sun"
    ]

    private let experienceTypes = [
        "Teach",
        "Demonstrate",
        "StoryTell",
        "Build",
        "Mentor",
        "Explore",
        "Discuss",
        "Practice"
    ]

    // MARK: - Validation

    // Sign-in is optional, but contact information is required.
    private var isFormValid: Bool {
        if title.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            return false
        }

        if audience.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            return false
        }

        if description.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            return false
        }

        if contactInfo.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            return false
        }

        if selectedDays.isEmpty {
            return false
        }

        return true
    }

    private func getValidationMessage() -> String {
        var missingFields: [String] = []

        if title.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            missingFields.append("Activity")
        }

        if audience.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            missingFields.append("People to connect with")
        }

        if selectedDays.isEmpty {
            missingFields.append("Available day")
        }

        if description.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            missingFields.append("Description")
        }

        if contactInfo.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            missingFields.append("Contact Info")
        }

        return """
        Please fill out the following required fields:

        • \(missingFields.joined(separator: "\n• "))
        """
    }

    // MARK: - Main View

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                headerView

                VStack(alignment: .leading, spacing: 30) {

                    activityInputSection

                    audienceInputSection

                    experienceTypeSection

                    capacitySection

                    daysSection

                    timeSection

                    locationSection

                    imageSection

                    descriptionSection

                    contactSection

                    previewSection

                    actionButtons
                }
                .padding(.horizontal, 30)
                .padding(.top, 35)
                .padding(.bottom, 45)
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .onReceive(eventManager.$formResetTrigger) { _ in
            resetForm()
        }
        .alert(
            "Missing Details",
            isPresented: $showValidationError
        ) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.black)

                Text("Bloop")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
            }

            Spacer()

            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(
                        color: .black.opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 25)
    }

    // MARK: - Activity Input

    private var activityInputSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("What are you looking to do?")

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray.opacity(0.5))

                TextField(
                    "e.g. rock climbing",
                    text: $title
                )
                .font(.system(size: 18))
                .textInputAutocapitalization(.sentences)
                .onChange(of: title) {
                    checkUnsavedChanges()
                }

                if !title.isEmpty {
                    Button {
                        title = ""
                        checkUnsavedChanges()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }

            Divider()
        }
    }

    // MARK: - Audience Input

    private var audienceInputSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(
                "Who are you looking to connect with?"
            )

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray.opacity(0.5))

                TextField(
                    "e.g. your name or adventurers",
                    text: $audience
                )
                .font(.system(size: 18))
                .textInputAutocapitalization(.never)
                .onChange(of: audience) {
                    checkUnsavedChanges()
                }

                if !audience.isEmpty {
                    Button {
                        audience = ""
                        checkUnsavedChanges()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }

            Divider()
        }
    }

    // MARK: - Experience Type

    private var experienceTypeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("What type of experience is it?")

            Menu {
                ForEach(
                    experienceTypes,
                    id: \.self
                ) { type in
                    Button {
                        selectedExperience = type
                        checkUnsavedChanges()
                    } label: {
                        if selectedExperience == type {
                            Label(
                                type,
                                systemImage: "checkmark"
                            )
                        } else {
                            Text(type)
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "tag")
                        .foregroundColor(.indigo)

                    Text(selectedExperience)
                        .foregroundColor(.black)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }

            Divider()
        }
    }

    // MARK: - Capacity

    private var capacitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("With how many people?")

            Text("\(Int(capacity)) people")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.indigo)

            HStack(spacing: 14) {
                Image(systemName: "person.fill")
                    .foregroundColor(.gray)

                Slider(
                    value: $capacity,
                    in: 1...20,
                    step: 1
                )
                .tint(.indigo)
                .onChange(of: capacity) {
                    checkUnsavedChanges()
                }

                Image(systemName: "person.3.fill")
                    .foregroundColor(.gray)
            }

            Divider()
        }
    }

    // MARK: - Days

    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Which days work for you?")

            HStack(spacing: 5) {
                ForEach(
                    weekDays,
                    id: \.self
                ) { day in
                    Button {
                        toggleDay(day)
                    } label: {
                        Text(day)
                            .font(
                                .system(
                                    size: 12,
                                    weight: .medium
                                )
                            )
                            .foregroundColor(
                                selectedDays.contains(day)
                                ? .indigo
                                : .gray.opacity(0.55)
                            )
                            .frame(
                                maxWidth: .infinity
                            )
                            .frame(height: 44)
                            .background(
                                selectedDays.contains(day)
                                ? Color.indigo.opacity(0.12)
                                : Color.clear
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()
        }
    }

    // MARK: - Time

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("At this time:")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.indigo)

                Spacer()

                ZStack {
                    DatePicker(
                        "",
                        selection: $startTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(.indigo)
                    .opacity(0.02)
                    .onChange(of: startTime) {
                        checkUnsavedChanges()
                    }

                    Text(formattedTime)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.indigo)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Color.indigo.opacity(0.12))
                        .clipShape(Capsule())
                        .allowsHitTesting(false)
                }
                .fixedSize()
            }

            Divider()
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: startTime)
    }
    
    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Where will it happen?")

            HStack(spacing: 12) {
                Image(systemName: "location")
                    .foregroundColor(.gray.opacity(0.6))

                TextField(
                    "Location (Optional)",
                    text: $location
                )
                .font(.system(size: 17))
                .onChange(of: location) {
                    checkUnsavedChanges()
                }

                if !location.isEmpty {
                    Button {
                        location = ""
                        checkUnsavedChanges()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }

            Divider()
        }
    }

    // MARK: - Image

    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Add an event image")

            if let selectedUIImage {
                Image(uiImage: selectedUIImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 190)
                    .clipped()
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20
                        )
                    )

                HStack {
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label(
                            "Change Image",
                            systemImage: "photo"
                        )
                        .foregroundColor(.indigo)
                    }

                    Spacer()

                    Button(role: .destructive) {
                        selectedPhotoItem = nil
                        selectedImageData = nil
//                        selectedUIImage = nil
                        checkUnsavedChanges()
                    } label: {
                        Label(
                            "Remove",
                            systemImage: "trash"
                        )
                    }
                }
            } else {
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)

                        Text("Select Image")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.indigo)
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
                    .background(
                        Color.indigo.opacity(0.06)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                        .stroke(
                            Color.indigo.opacity(0.18),
                            style: StrokeStyle(
                                lineWidth: 1.5,
                                dash: [6]
                            )
                        )
                    }
                }
            }

            if let uploadErrorMessage {
                Text(uploadErrorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Divider()
        }
        .onChange(of: selectedPhotoItem) {
            guard let selectedPhotoItem else {
                return
            }

            Task {
                await loadSelectedImage(
                    from: selectedPhotoItem
                )
            }
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Tell people more about it")

            TextEditor(text: $description)
                .frame(minHeight: 100)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(
                    Color.gray.opacity(0.06)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 14
                    )
                )
                .overlay(alignment: .topLeading) {
                    if description.isEmpty {
                        Text(
                            "Description (Required)"
                        )
                        .foregroundColor(
                            .gray.opacity(0.55)
                        )
                        .padding(.horizontal, 15)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                    }
                }
                .onChange(of: description) {
                    checkUnsavedChanges()
                }
        }
    }

    // MARK: - Contact

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("How can people contact you?")

            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .foregroundColor(.gray.opacity(0.6))

                TextField(
                    "Email or Phone (Required)",
                    text: $contactInfo
                )
                .font(.system(size: 17))
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .onChange(of: contactInfo) {
                    checkUnsavedChanges()
                }

                if !contactInfo.isEmpty {
                    Button {
                        contactInfo = ""
                        checkUnsavedChanges()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }

            Divider()
        }
    }

    // MARK: - Preview

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Preview:")

            previewText
                .font(
                    .system(
                        size: 29,
                        weight: .bold
                    )
                )
                .lineSpacing(7)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(36)
                .background(
                    Color.indigo.opacity(0.05)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 24
                    )
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: 24
                    )
                    .stroke(
                        Color.indigo.opacity(0.1),
                        style: StrokeStyle(
                            lineWidth: 2,
                            dash: [7]
                        )
                    )
                }

            Text("Looking good?")
                .font(.caption.weight(.semibold))
                .foregroundColor(
                    .gray.opacity(0.6)
                )
                .frame(maxWidth: .infinity)
        }
    }

    private var previewText: Text {
        let personName =
            authManager.profile?.full_name
            ?? authManager.profile?.username
            ?? "Someone"

        let activity = title.isEmpty
            ? "something fun"
            : title

        let targetAudience = audience.isEmpty
            ? "new people"
            : audience

        let dayText = formattedSelectedDays

        return Text(personName)
            .foregroundColor(.indigo)

        + Text(" wants ")
            .foregroundColor(.primary)

        + Text("\(Int(capacity)) ")
            .foregroundColor(.orange)

        + Text(targetAudience)
            .foregroundColor(.blue)

        + Text(" to go ")
            .foregroundColor(.primary)

        + Text(activity)
            .foregroundColor(.green)

        + Text(" on ")
            .foregroundColor(.primary)

        + Text(dayText)
            .foregroundColor(.indigo)
    }

    // MARK: - Buttons

    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button {
                submitForm()
            } label: {
                HStack(spacing: 8) {
                    if isUploading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(
                            systemName: "checkmark.circle.fill"
                        )

                        Text("Find my people")
                            .fontWeight(.medium)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.indigo)
                .clipShape(Capsule())
            }
            .disabled(isUploading)
            .opacity(isUploading ? 0.7 : 1)

            Button {
                eventManager.formResetTrigger = UUID()
                eventManager.selectedTab = 0
            } label: {
                Label(
                    "Cancel",
                    systemImage: "xmark.circle"
                )
                .foregroundColor(.indigo)
            }
        }
    }

    // MARK: - Helper Views

    private func sectionTitle(
        _ text: String
    ) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(
                Color.gray.opacity(0.6)
            )
    }

    // MARK: - Actions

    private func submitForm() {
        guard !isUploading else {
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
        
        if sortedDays.count == 2 {
            return "\(fullDayName(sortedDays[0])) or \(fullDayName(sortedDays[1]))"
        }
        
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

//    @MainActor
//    private func saveEvent() async {
//        isUploading = true
//        uploadErrorMessage = nil
//
//        defer {
//            isUploading = false
//        }
//
//        do {
//            let imageURL = try await uploadEventImage()
//
//            let timeFormatter = DateFormatter()
//            timeFormatter.dateStyle = .none
//            timeFormatter.timeStyle = .short
//
//            let timeString = timeFormatter.string(
//                from: startTime
//            )
//
//            let trimmedTitle = title.trimmingCharacters(
//                in: .whitespacesAndNewlines
//            )
//
//            let trimmedAudience =
//                audience.trimmingCharacters(
//                    in: .whitespacesAndNewlines
//                )
//
//            let trimmedDescription =
//                description.trimmingCharacters(
//                    in: .whitespacesAndNewlines
//                )
//
//            let trimmedContact =
//                contactInfo.trimmingCharacters(
//                    in: .whitespacesAndNewlines
//                )
//
//            let hostName =
//                authManager.profile?.full_name
//                ?? authManager.profile?.username
//                ?? "Guest"
//
//            /*
//             Audience is not currently a separate
//             DetailedEvent or database field, so it
//             is included in the description.
//             */
//            let savedDescription = """
//            Looking to connect with: \(trimmedAudience)
//
//            \(trimmedDescription)
//            """
//
//            let newEvent = DetailedEvent(
//                createdBy: authManager.userID,
//                title: trimmedTitle,
//                status: .proposed,
//                hostName: hostName,
//                location: location.isEmpty
//                    ? "TBD"
//                    : location,
//                date: formattedSelectedDays,
//                time: timeString,
//                description: savedDescription,
//                experienceType: selectedExperience,
//                capacity: capacity,
//                contactEmail: trimmedContact,
//                imgUrl: imageURL
//            )
//
//            print(
//                "🖼️ New event image URL:",
//                newEvent.imgUrl ?? "nil"
//            )
//
//            let didCreateEvent =
//                await eventManager.createEvent(
//                    newEvent
//                )
//
//            if didCreateEvent {
//                eventManager.formResetTrigger = UUID()
//                eventManager.selectedTab = 0
//            } else {
//                validationMessage =
//                    eventManager.errorMessage.isEmpty
//                    ? "Event could not be created."
//                    : eventManager.errorMessage
//
//                showValidationError = true
//            }
//
//        } catch {
//            let errorMessage =
//                "Image upload failed: \(error.localizedDescription)"
//
//            uploadErrorMessage = errorMessage
//            validationMessage = errorMessage
//            showValidationError = true
//
//            print(
//                "❌ Image upload failed:",
//                error
//            )
//        }
//    }
    // MARK: - Save Event

        @MainActor
        private func saveEvent() async {
            isUploading = true
            uploadErrorMessage = nil

            defer {
                isUploading = false
            }

            do {
                // 1. 获取上传后的图片 URL（如果没有则默认为空字符串，匹配最新非可选 String 类型）
                let imageURL = try await uploadEventImage() ?? ""

                let trimmedActivity = title.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedTarget = audience.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedLocation = location.isEmpty ? "TBD" : location
                let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedContact = contactInfo.trimmingCharacters(in: .whitespacesAndNewlines)

                let hostName = authManager.profile?.full_name
                    ?? authManager.profile?.username
                    ?? "Guest"

                // 🌟 核心修正：完美适配最新 Model 字段与数据类型
                let newEvent = DetailedEvent(
                    id: UUID(),
                    hostName: hostName,
                    location: trimmedLocation,
                    experienceType: selectedExperience,
                    created_by: authManager.userID,
                    activity: trimmedActivity,
                    connectionTarget: trimmedTarget,
                    minPeople: 1,                    // 临时保底值，可后续绑定 UI
                    maxPeople: Int(capacity),        // 将 Slider 的 Double 转为 Int
                    selectedDays: Array(selectedDays), // 将 Set 转为 Array
                    time: startTime,                 // 直接传入 Date 实例，解决 String 转 Date 报错
                    imgUrl: imageURL,                // 传入非可选 String
                    isSolid: false,                  // 替代旧版的 .proposed 状态
                    likeCount: 0,
                    joinedCount: 0
                )

                print("🖼️ New event ready to upload:", newEvent.generatedTitle)

                let didCreateEvent = await eventManager.createEvent(newEvent)

                if didCreateEvent {
                    eventManager.formResetTrigger = UUID()
                    eventManager.selectedTab = 0
                } else {
                    validationMessage = eventManager.errorMessage.isEmpty
                        ? "Event could not be created."
                        : eventManager.errorMessage

                    showValidationError = true
                }

            } catch {
                let errorMessage = "Image upload failed: \(error.localizedDescription)"
                uploadErrorMessage = errorMessage
                validationMessage = errorMessage
                showValidationError = true
                print("❌ Image upload failed:", error)
            }
        }
    
    
    // MARK: - Image Loading

    @MainActor
    private func loadSelectedImage(
        from item: PhotosPickerItem
    ) async {
        do {
            guard
                let data = try await item.loadTransferable(
                    type: Data.self
                ),
                let image = UIImage(data: data)
            else {
                uploadErrorMessage =
                    "The selected image could not be loaded."
                return
            }

            guard
                let compressedData = image.jpegData(
                    compressionQuality: 0.75
                )
            else {
                uploadErrorMessage =
                    "The selected image could not be processed."
                return
            }

            selectedUIImage = image
            selectedImageData = compressedData
            uploadErrorMessage = nil

            checkUnsavedChanges()

        } catch {
            uploadErrorMessage =
                "Failed to load image: \(error.localizedDescription)"
        }
    }

    // MARK: - Image Upload

    private func uploadEventImage() async throws -> String? {
        guard let selectedImageData else {
            return nil
        }

        /*
         This must exactly match the bucket name
         in Supabase Storage.
         */
        let bucketName = "imgUrl"

        let fileName =
            "\(UUID().uuidString).jpg"

        let filePath =
            "events/\(fileName)"

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

        let publicURL =
            try SupabaseManager.shared.client.storage
                .from(bucketName)
                .getPublicURL(
                    path: filePath
                )

        print(
            "✅ Uploaded image URL:",
            publicURL.absoluteString
        )

        return publicURL.absoluteString
    }
}


#Preview {
    ExperienceCreateView()
        .environmentObject(EventManager())
        .environmentObject(AuthManager())
}
