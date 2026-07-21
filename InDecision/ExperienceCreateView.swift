////
////  ExperienceCreateView.swift
////  InDecision
////
////  Created by David-Ioan Dumitrescu on 16/7/2026.
////  Updated by Lisa on 20/7/2026.
//
//import SwiftUI
//import Supabase
//import PhotosUI
//import UIKit
//
//struct ExperienceCreateView: View {
//    
//    @EnvironmentObject var eventManager: EventManager
//    @EnvironmentObject var authManager: AuthManager
//
//    
//
//    @State var activity: String = ""
//    @State var connectionTarget: String = ""
//    @State var minPeople: Double = 0.0
//    @State var maxPeople: Double = 1.0
//    @State private var selectedDays: Set<String> = [
//            "Mon",
//            "Tue"
//        ]
//    @State  var time: Date = Date.now
//    @State  var isSolid: Bool = false
//    @State  var location: String = ""
//    @State  var experienceType: String = ""
//    @State  var description: String = ""
//    
//    @State  var showValidationError = false
//    @State  var validationMessage = ""
//    @State  var imgUrl = ""
//
//    // MARK: - Image State
//
//    @State private var selectedPhotoItem: PhotosPickerItem?
//    @State private var selectedImageData: Data?
//    @State private var selectedUIImage: UIImage?
//
//    // MARK: - UI State
//
//    @State private var isUploading = false
//    @State private var uploadErrorMessage: String?
//
//    
//
//    private let weekDays = [
//        "Mon",
//        "Tue",
//        "Wed",
//        "Thu",
//        "Fri",
//        "Sat",
//        "Sun"
//    ]
//
//    private let experienceTypes = [
//        "Teach",
//        "Demonstrate",
//        "StoryTell",
//        "Build",
//        "Mentor",
//        "Explore",
//        "Discuss",
//        "Practice"
//    ]
//
//    // MARK: - Validation
//
//    // Sign-in is optional, but contact information is required.
//    private var isFormValid: Bool {
//        if activity.trimmingCharacters(
//            in: .whitespacesAndNewlines
//        ).isEmpty {
//            return false
//        }
//
//        if connectionTarget.trimmingCharacters(
//            in: .whitespacesAndNewlines
//        ).isEmpty {
//            return false
//        }
//
//        if description.trimmingCharacters(
//            in: .whitespacesAndNewlines
//        ).isEmpty {
//            return false
//        }
//
//        
//        if selectedDays.isEmpty {
//            return false
//        }
//
//        return true
//    }
//
//    private func getValidationMessage() -> String {
//        var missingFields: [String] = []
//
//        if activity.trimmingCharacters(
//            in: .whitespacesAndNewlines
//        ).isEmpty {
//            missingFields.append("Activity")
//        }
//
//        if connectionTarget.trimmingCharacters(
//            in: .whitespacesAndNewlines
//        ).isEmpty {
//            missingFields.append("People to connect with")
//        }
//
//        if selectedDays.isEmpty {
//            missingFields.append("Available day")
//        }
//
//        if description.trimmingCharacters(
//            in: .whitespacesAndNewlines
//        ).isEmpty {
//            missingFields.append("Description")
//        }
//
//        
//        return """
//        Please fill out the following required fields:
//
//        • \(missingFields.joined(separator: "\n• "))
//        """
//    }
//
//    // MARK: - Main View
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 0) {
//
//                headerView
//
//                VStack(alignment: .leading, spacing: 30) {
//
//                    activityInputSection
//
//                    audienceInputSection
//
//                    experienceTypeSection
//
//                    capacitySection
//
//                    daysSection
//
//                    timeSection
//
//                    locationSection
//
//                    imageSection
//
//                    descriptionSection
//
//                    //contactSection
//
//                    previewSection
//
//                    actionButtons
//                }
//                .padding(.horizontal, 30)
//                .padding(.top, 35)
//                .padding(.bottom, 45)
//            }
//        }
//        .background(Color.white)
//        .navigationBarBackButtonHidden(true)
//        .onReceive(eventManager.$formResetTrigger) { _ in
//            resetForm()
//        }
//        .alert(
//            "Missing Details",
//            isPresented: $showValidationError
//        ) {
//            Button("Got it", role: .cancel) { }
//        } message: {
//            Text(validationMessage)
//        }
//    }
//
//    // MARK: - Header
//
//    private var headerView: some View {
//        HStack {
//            HStack(spacing: 10) {
//                Image(systemName: "person.3.fill")
//                    .font(.system(size: 30))
//                    .foregroundColor(.black)
//
//                Text("Bloop")
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.black)
//            }
//
//            Spacer()
//
//            NavigationLink(destination: ProfileView()) {
//                Image(systemName: "person.crop.circle.fill")
//                    .font(.system(size: 44))
//                    .foregroundColor(.black)
//                    .background(Color.white)
//                    .clipShape(Circle())
//                    .shadow(
//                        color: .black.opacity(0.1),
//                        radius: 8,
//                        x: 0,
//                        y: 4
//                    )
//            }
//        }
//        .padding(.horizontal, 30)
//        .padding(.top, 25)
//    }
//
//    // MARK: - Activity Input
//
//    private var activityInputSection: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            sectionTitle("What are you looking to do?")
//
//            HStack(spacing: 12) {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.gray.opacity(0.5))
//
//                TextField(
//                    "e.g. rock climbing",
//                    text: $activity
//                )
//                .font(.system(size: 18))
//                .textInputAutocapitalization(.sentences)
//                .onChange(of: activity) {
//                    checkUnsavedChanges()
//                }
//
//                if !activity.isEmpty {
//                    Button {
//                        activity = ""
//                        checkUnsavedChanges()
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.gray.opacity(0.5))
//                    }
//                }
//            }
//
//            Divider()
//        }
//    }
//
//    // MARK: - Audience Input
//
//    private var audienceInputSection: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            sectionTitle(
//                "Who are you looking to connect with?"
//            )
//
//            HStack(spacing: 12) {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.gray.opacity(0.5))
//
//                TextField(
//                    "e.g. your name or adventurers",
//                    text: $connectionTarget
//                )
//                .font(.system(size: 18))
//                .textInputAutocapitalization(.never)
//                .onChange(of: connectionTarget) {
//                    checkUnsavedChanges()
//                }
//
//                if !connectionTarget.isEmpty {
//                    Button {
//                        connectionTarget = ""
//                        checkUnsavedChanges()
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.gray.opacity(0.5))
//                    }
//                }
//            }
//
//            Divider()
//        }
//    }
//
//    // MARK: - Experience Type
//
//    private var experienceTypeSection: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            sectionTitle("What type of experience is it?")
//
//            Menu {
//                ForEach(
//                    experienceTypes,
//                    id: \.self
//                ) { type in
//                    Button {
//                        experienceType = type
//                        checkUnsavedChanges()
//                    } label: {
//                        if experienceType == type {
//                            Label(
//                                type,
//                                systemImage: "checkmark"
//                            )
//                        } else {
//                            Text(type)
//                        }
//                    }
//                }
//            } label: {
//                HStack {
//                    Image(systemName: "tag")
//                        .foregroundColor(.indigo)
//
//                    Text(experienceType)
//                        .foregroundColor(.black)
//
//                    Spacer()
//
//                    Image(systemName: "chevron.down")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//                .padding(.vertical, 4)
//            }
//
//            Divider()
//        }
//    }
//
//    // MARK: - Capacity
//
//    private var capacitySection: some View {
//        
//        return VStack(alignment: .leading, spacing: 16) {
//            sectionTitle("With how many people?")
//            
//            if (maxPeople < 2){
//                Text("one person")
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.indigo)
//            }
//            else if (minPeople == 0){
//                Text("up to \(Int(maxPeople)) people")
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.indigo)
//            }
//            else if (Int(minPeople) == Int(maxPeople)){
//                Text("\(Int(maxPeople)) people")
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.indigo)
//            }
//            else {
//                Text("\(Int(minPeople)) to \(Int(maxPeople)) people")
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.indigo)
//            }
//            
//            
//            HStack(spacing: 14) {
//                Image(systemName: "person.fill")
//                    .foregroundColor(.gray)
//                
//                RangeSlider(
//                    lowerValue: $minPeople,
//                    upperValue: $maxPeople,
//                    bounds: 1...20
//                )
//                .padding()
//                
//                Image(systemName: "person.3.fill")
//                    .foregroundColor(.gray)
//            }
//            
//            Divider()
//        }
//    }
//
//    // MARK: - Days
//
//    private var daysSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            sectionTitle("Which days work for you?")
//
//            HStack(spacing: 5) {
//                ForEach(
//                    weekDays,
//                    id: \.self
//                ) { day in
//                    Button {
//                        toggleDay(day)
//                    } label: {
//                        Text(day)
//                            .font(
//                                .system(
//                                    size: 12,
//                                    weight: .medium
//                                )
//                            )
//                            .foregroundColor(
//                                selectedDays.contains(day)
//                                ? .indigo
//                                : .gray.opacity(0.55)
//                            )
//                            .frame(
//                                maxWidth: .infinity
//                            )
//                            .frame(height: 44)
//                            .background(
//                                selectedDays.contains(day)
//                                ? Color.indigo.opacity(0.12)
//                                : Color.clear
//                            )
//                            .clipShape(Circle())
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//
//            Divider()
//        }
//    }
//
//    // MARK: - Time
//
//    private var timeSection: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            HStack {
//                Text("At this time:")
//                    .font(.system(size: 17, weight: .medium))
//                    .foregroundColor(.indigo)
//
//                Spacer()
//
//                ZStack {
//                    DatePicker(
//                        "",
//                        selection: $time,
//                        displayedComponents: .hourAndMinute
//                    )
//                    .labelsHidden()
//                    .datePickerStyle(.compact)
//                    .tint(.indigo)
//                    .opacity(0.02)
//                    .onChange(of: time) {
//                        checkUnsavedChanges()
//                    }
//
//                    Text(formattedTime)
//                        .font(.system(size: 17, weight: .medium))
//                        .foregroundColor(.indigo)
//                        .padding(.horizontal, 14)
//                        .padding(.vertical, 9)
//                        .background(Color.indigo.opacity(0.12))
//                        .clipShape(Capsule())
//                        .allowsHitTesting(false)
//                }
//                .fixedSize()
//            }
//
//            Divider()
//        }
//    }
//    
//    private var formattedTime: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "h:mm a"
//        return formatter.string(from: time)
//    }
//    
//    // MARK: - Location
//
//    private var locationSection: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            sectionTitle("Where will it happen?")
//
//            HStack(spacing: 12) {
//                Image(systemName: "location")
//                    .foregroundColor(.gray.opacity(0.6))
//
//                TextField(
//                    "Location (Optional)",
//                    text: $location
//                )
//                .font(.system(size: 17))
//                .onChange(of: location) {
//                    checkUnsavedChanges()
//                }
//
//                if !location.isEmpty {
//                    Button {
//                        location = ""
//                        checkUnsavedChanges()
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.gray.opacity(0.5))
//                    }
//                }
//            }
//
//            Divider()
//        }
//    }
//
//    // MARK: - Image
//
//    private var imageSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            sectionTitle("Add an event image")
//
//            if let selectedUIImage {
//                Image(uiImage: selectedUIImage)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 190)
//                    .clipped()
//                    .clipShape(
//                        RoundedRectangle(
//                            cornerRadius: 20
//                        )
//                    )
//
//                HStack {
//                    PhotosPicker(
//                        selection: $selectedPhotoItem,
//                        matching: .images,
//                        photoLibrary: .shared()
//                    ) {
//                        Label(
//                            "Change Image",
//                            systemImage: "photo"
//                        )
//                        .foregroundColor(.indigo)
//                    }
//
//                    Spacer()
//
//                    Button(role: .destructive) {
//                        selectedPhotoItem = nil
//                        selectedImageData = nil
////                        selectedUIImage = nil
//                        checkUnsavedChanges()
//                    } label: {
//                        Label(
//                            "Remove",
//                            systemImage: "trash"
//                        )
//                    }
//                }
//            } else {
//                PhotosPicker(
//                    selection: $selectedPhotoItem,
//                    matching: .images,
//                    photoLibrary: .shared()
//                ) {
//                    HStack {
//                        Image(systemName: "photo.badge.plus")
//                            .font(.title2)
//
//                        Text("Select Image")
//                            .fontWeight(.medium)
//                    }
//                    .foregroundColor(.indigo)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 90)
//                    .background(
//                        Color.indigo.opacity(0.06)
//                    )
//                    .clipShape(
//                        RoundedRectangle(
//                            cornerRadius: 16
//                        )
//                    )
//                    .overlay {
//                        RoundedRectangle(
//                            cornerRadius: 16
//                        )
//                        .stroke(
//                            Color.indigo.opacity(0.18),
//                            style: StrokeStyle(
//                                lineWidth: 1.5,
//                                dash: [6]
//                            )
//                        )
//                    }
//                }
//            }
//
//            if let uploadErrorMessage {
//                Text(uploadErrorMessage)
//                    .font(.caption)
//                    .foregroundColor(.red)
//            }
//
//            Divider()
//        }
//        .onChange(of: selectedPhotoItem) {
//            guard let selectedPhotoItem else {
//                return
//            }
//
//            Task {
//                await loadSelectedImage(
//                    from: selectedPhotoItem
//                )
//            }
//        }
//    }
//
//    // MARK: - Description
//
//    private var descriptionSection: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            sectionTitle("Tell people more about it")
//
//            TextEditor(text: $description)
//                .frame(minHeight: 100)
//                .padding(10)
//                .scrollContentBackground(.hidden)
//                .background(
//                    Color.gray.opacity(0.06)
//                )
//                .clipShape(
//                    RoundedRectangle(
//                        cornerRadius: 14
//                    )
//                )
//                .overlay(alignment: .topLeading) {
//                    if description.isEmpty {
//                        Text(
//                            "Description (Required)"
//                        )
//                        .foregroundColor(
//                            .gray.opacity(0.55)
//                        )
//                        .padding(.horizontal, 15)
//                        .padding(.vertical, 18)
//                        .allowsHitTesting(false)
//                    }
//                }
//                .onChange(of: description) {
//                    checkUnsavedChanges()
//                }
//        }
//    }
//
//    
//    // MARK: - Contact
//    /*
//    private var contactSection: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            sectionTitle("How can people contact you?")
//
//            HStack(spacing: 12) {
//                Image(systemName: "envelope")
//                    .foregroundColor(.gray.opacity(0.6))
//
//                TextField(
//                    "Email or Phone (Required)",
//                    text: $contactInfo
//                )
//                .font(.system(size: 17))
//                .textInputAutocapitalization(.never)
//                .keyboardType(.emailAddress)
//                .onChange(of: contactInfo) {
//                    checkUnsavedChanges()
//                }
//
//                if !contactInfo.isEmpty {
//                    Button {
//                        contactInfo = ""
//                        checkUnsavedChanges()
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.gray.opacity(0.5))
//                    }
//                }
//            }
//
//            Divider()
//        }
//    }
//     */
//
//    // MARK: - Preview
//
//    private var previewSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            sectionTitle("Preview:")
//
//            previewText
//                .font(
//                    .system(
//                        size: 29,
//                        weight: .bold
//                    )
//                )
//                .lineSpacing(7)
//                .frame(
//                    maxWidth: .infinity,
//                    alignment: .leading
//                )
//                .padding(36)
//                .background(
//                    Color.indigo.opacity(0.05)
//                )
//                .clipShape(
//                    RoundedRectangle(
//                        cornerRadius: 24
//                    )
//                )
//                .overlay {
//                    RoundedRectangle(
//                        cornerRadius: 24
//                    )
//                    .stroke(
//                        Color.indigo.opacity(0.1),
//                        style: StrokeStyle(
//                            lineWidth: 2,
//                            dash: [7]
//                        )
//                    )
//                }
//
//            Text("Looking good?")
//                .font(.caption.weight(.semibold))
//                .foregroundColor(
//                    .gray.opacity(0.6)
//                )
//                .frame(maxWidth: .infinity)
//        }
//    }
//
//    private var previewText: Text {
//            let hostName = authManager.profile?.full_name
//                ?? authManager.profile?.username
//                ?? "Someone"
//
//            let safeActivity = activity.trimmingCharacters(in: .whitespaces).isEmpty
//                ? "do something fun"
//                : activity
//
//            let safeTarget = connectionTarget.trimmingCharacters(in: .whitespaces).isEmpty
//                ? "new people"
//                : connectionTarget
//
//            // Convert Doubles to Ints to remove the .0 decimals
//            let minP = Int(minPeople)
//            let maxP = Int(maxPeople)
//            let peopleString = minP == maxP ? "\(maxP)" : "\(minP)-\(maxP)"
//
//            // Using the exact stylized formatting from your DetailedEvent model
//            return Text("""
//                \(Text("\(hostName) ").foregroundColor(.blue))\
//                \(Text("wants ").foregroundColor(.primary))\
//                \(Text("\(peopleString) ").foregroundColor(.orange))\
//                \(Text("\(safeTarget) ").foregroundColor(.blue))\
//                \(Text("to \ngo ").foregroundColor(.primary))\
//                \(Text("\(safeActivity) ").foregroundColor(.green))\
//                \(Text("with ").foregroundColor(.primary))\
//                \(styledDaysText)
//                """)
//        }
//
//        // Helper to stylize the days exactly like the DetailedEvent model
//        private var styledDaysText: Text {
//            let sortedDays = selectedDays.sorted { dayIndex($0) < dayIndex($1) }
//            
//            if sortedDays.isEmpty {
//                return Text("anytime").foregroundColor(.blue)
//            }
//            if sortedDays.count == 1 {
//                return Text(fullDayName(sortedDays[0])).foregroundColor(.blue)
//            }
//            if sortedDays.count == 2 {
//                return Text(fullDayName(sortedDays[0])).foregroundColor(.blue)
//                    + Text(" or ").foregroundColor(.primary)
//                    + Text(fullDayName(sortedDays[1])).foregroundColor(.blue)
//            }
//            
//            var multiDayText = Text("")
//            for (index, day) in sortedDays.enumerated() {
//                if index == sortedDays.count - 1 {
//                    multiDayText = multiDayText + Text("or ").foregroundColor(.primary) + Text(fullDayName(day)).foregroundColor(.blue)
//                } else {
//                    multiDayText = multiDayText + Text("\(fullDayName(day)), ").foregroundColor(.blue)
//                }
//            }
//            return multiDayText
//        }
//
//    // MARK: - Buttons
//
//    private var actionButtons: some View {
//        VStack(spacing: 16) {
//            Button {
//                submitForm()
//            } label: {
//                HStack(spacing: 8) {
//                    if isUploading {
//                        ProgressView()
//                            .tint(.white)
//                    } else {
//                        Image(
//                            systemName: "checkmark.circle.fill"
//                        )
//
//                        Text("Find my people")
//                            .fontWeight(.medium)
//                    }
//                }
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .frame(height: 52)
//                .background(Color.indigo)
//                .clipShape(Capsule())
//            }
//            .disabled(isUploading)
//            .opacity(isUploading ? 0.7 : 1)
//
//            Button {
//                eventManager.formResetTrigger = UUID()
//                eventManager.selectedTab = 0
//            } label: {
//                Label(
//                    "Cancel",
//                    systemImage: "xmark.circle"
//                )
//                .foregroundColor(.indigo)
//            }
//        }
//    }
//
//    // MARK: - Helper Views
//
//    private func sectionTitle(
//        _ text: String
//    ) -> some View {
//        Text(text)
//            .font(.subheadline.weight(.semibold))
//            .foregroundColor(
//                Color.gray.opacity(0.6)
//            )
//    }
//
//    // MARK: - Actions
//
//    private func submitForm() {
//        guard !isUploading else {
//            return
//        }
//
//        if isFormValid {
//            Task {
//                await saveEvent()
//            }
//        } else {
//            validationMessage = getValidationMessage()
//            showValidationError = true
//        }
//    }
//
//    private func toggleDay(_ day: String) {
//        if selectedDays.contains(day) {
//            selectedDays.remove(day)
//        } else {
//            selectedDays.insert(day)
//        }
//
//        checkUnsavedChanges()
//    }
//
//    private var formattedSelectedDays: String {
//        let sortedDays = selectedDays.sorted {
//            dayIndex($0) < dayIndex($1)
//        }
//
//        guard !sortedDays.isEmpty else {
//            return "any day"
//        }
//
//        if sortedDays.count == 1 {
//            return fullDayName(sortedDays[0])
//        }
//        
//        if sortedDays.count == 2 {
//            return "\(fullDayName(sortedDays[0])) or \(fullDayName(sortedDays[1]))"
//        }
//        
//        return "multiple days"
//    }
//
//    private func dayIndex(_ day: String) -> Int {
//        weekDays.firstIndex(of: day)
//        ?? weekDays.count
//    }
//
//    private func fullDayName(
//        _ abbreviatedDay: String
//    ) -> String {
//        switch abbreviatedDay {
//        case "Mon":
//            return "monday"
//        case "Tue":
//            return "tuesday"
//        case "Wed":
//            return "wednesday"
//        case "Thu":
//            return "thursday"
//        case "Fri":
//            return "friday"
//        case "Sat":
//            return "saturday"
//        case "Sun":
//            return "sunday"
//        default:
//            return abbreviatedDay
//        }
//    }
//
//    // MARK: - Unsaved Changes
//
//    private func checkUnsavedChanges() {
//        let hasTextChanges =
//            !activity.isEmpty
//            || !connectionTarget.isEmpty
//            || !location.isEmpty
//            || !description.isEmpty
//
//        let hasOtherChanges =
//            maxPeople != 5
//            || selectedDays != ["Mon", "Tue"]
//            || selectedUIImage != nil
//
//        let isDirty =
//            hasTextChanges
//            || hasOtherChanges
//
//        if eventManager.hasUnsavedChanges != isDirty {
//            eventManager.hasUnsavedChanges = isDirty
//        }
//    }
//
//    private func resetForm() {
//        activity = ""
//        connectionTarget = ""
//        location = ""
//        description = ""
//
//        experienceType = "Explore"
//        maxPeople = 5
//        time = Date()
//        selectedDays = ["Mon", "Tue"]
//
//        selectedPhotoItem = nil
//        selectedImageData = nil
//        selectedUIImage = nil
//
//        uploadErrorMessage = nil
//        isUploading = false
//
//        eventManager.hasUnsavedChanges = false
//    }
//
//    // MARK: - Save Event
//
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
//                from: time
//            )
//
//            let trimmedTitle = activity.trimmingCharacters(
//                in: .whitespacesAndNewlines
//            )
//
//            let trimmedAudience =
//                connectionTarget.trimmingCharacters(
//                    in: .whitespacesAndNewlines
//                )
//
//            let trimmedDescription =
//                description.trimmingCharacters(
//                    in: .whitespacesAndNewlines
//                )
//            /*
//            let trimmedContact =
//                contactInfo.trimmingCharacters(
//                    in: .whitespacesAndNewlines
//                )
//             */
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
//            let newEvent = DetailedEvent(hostName: hostName,location: location, experienceType: experienceType, created_by: authManager.userID!, activity: activity, connectionTarget: connectionTarget,  minPeople: minPeople, maxPeople: maxPeople, selectedDays: Array(selectedDays).sorted(), time: time, imgUrl: imgUrl, description: description, likeCount: 0, joinedCount: 1)
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
//
//    // MARK: - Image Loading
//
//    @MainActor
//    private func loadSelectedImage(
//        from item: PhotosPickerItem
//    ) async {
//        do {
//            guard
//                let data = try await item.loadTransferable(
//                    type: Data.self
//                ),
//                let image = UIImage(data: data)
//            else {
//                uploadErrorMessage =
//                    "The selected image could not be loaded."
//                return
//            }
//
//            guard
//                let compressedData = image.jpegData(
//                    compressionQuality: 0.75
//                )
//            else {
//                uploadErrorMessage =
//                    "The selected image could not be processed."
//                return
//            }
//
//            selectedUIImage = image
//            selectedImageData = compressedData
//            uploadErrorMessage = nil
//
//            checkUnsavedChanges()
//
//        } catch {
//            uploadErrorMessage =
//                "Failed to load image: \(error.localizedDescription)"
//        }
//    }
//
//    // MARK: - Image Upload
//
//    private func uploadEventImage() async throws -> String? {
//        guard let selectedImageData else {
//            return nil
//        }
//
//        /*
//         This must exactly match the bucket name
//         in Supabase Storage.
//         */
//        let bucketName = "imgUrl"
//
//        let fileName =
//            "\(UUID().uuidString).jpg"
//
//        let filePath =
//            "events/\(fileName)"
//
//        try await SupabaseManager.shared.client.storage
//            .from(bucketName)
//            .upload(
//                filePath,
//                data: selectedImageData,
//                options: FileOptions(
//                    cacheControl: "3600",
//                    contentType: "image/jpeg",
//                    upsert: false
//                )
//            )
//
//        let publicURL =
//            try SupabaseManager.shared.client.storage
//                .from(bucketName)
//                .getPublicURL(
//                    path: filePath
//                )
//
//        print(
//            "✅ Uploaded image URL:",
//            publicURL.absoluteString
//        )
//
//        return publicURL.absoluteString
//    }
//}
//
//
//#Preview {
//    ExperienceCreateView()
//        .environmentObject(EventManager())
//        .environmentObject(AuthManager())
//}

import SwiftUI
import Supabase
import PhotosUI
import UIKit

struct ExperienceCreateView: View {
    
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var authManager: AuthManager

    @State var activity: String = ""
    @State var connectionTarget: String = ""
    @State var minPeople: Double = 0.0
    @State var maxPeople: Double = 1.0
    @State private var selectedDays: Set<String> = [
            "Mon",
            "Tue"
        ]
    @State  var time: Date = Date.now
    @State  var isSolid: Bool = false
    @State  var location: String = ""
    @State  var experienceType: String = ""
    @State  var description: String = ""
    
    @State  var showValidationError = false
    @State  var validationMessage = ""
    @State  var imgUrl = ""

    // MARK: - Theme Colors
    private let bgOrange = Color(red: 0.98, green: 0.55, blue: 0.15)
    private let accentCyan = Color(red: 0.10, green: 0.85, blue: 0.90)

    // MARK: - Image State

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedUIImage: UIImage?

    // MARK: - UI State

    @State private var isUploading = false
    @State private var uploadErrorMessage: String?

    

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
        if activity.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            return false
        }

        if connectionTarget.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            return false
        }

        // if description.trimmingCharacters(
        //     in: .whitespacesAndNewlines
        // ).isEmpty {
        //     return false
        // }

        
        if selectedDays.isEmpty {
            return false
        }

        return true
    }

    private func getValidationMessage() -> String {
        var missingFields: [String] = []

        if activity.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            missingFields.append("Activity")
        }

        if connectionTarget.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty {
            missingFields.append("People to connect with")
        }

        if selectedDays.isEmpty {
            missingFields.append("Available day")
        }

        // if description.trimmingCharacters(
        //     in: .whitespacesAndNewlines
        // ).isEmpty {
        //     missingFields.append("Description")
        // }

        
        return """
        Please fill out the following required fields:

        • \(missingFields.joined(separator: "\n• "))
        """
    }

    // MARK: - Main View

    var body: some View {
        ZStack {
            // 1. Background Layers
            bgOrange.ignoresSafeArea()
            
            // Bottom Right Staggered Shape
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        accentCyan.frame(width: 130, height: 70)
                        accentCyan.frame(width: 250, height: 70)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)

            // 2. Main Content Layer
            ScrollView(.vertical, showsIndicators: false) {
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

                        // imageSection

                        // descriptionSection

                        previewSection
                        
                        Spacer(minLength: 20)

                        actionButtons
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 35)
                    .padding(.bottom, 120) // Extra padding for the tab bar
                }
            }
        }
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
                    .foregroundColor(.white)

                Text("Bloop")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()

            NavigationLink(destination: ProfileDestinationView()) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Activity Input

    private var activityInputSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("What are you looking to do?")

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))

                TextField(
                    "e.g. rock climbing",
                    text: $activity
                )
                .font(.system(size: 18))
                .foregroundColor(.white)
                .textInputAutocapitalization(.sentences)
                .onChange(of: activity) {
                    checkUnsavedChanges()
                }

                if !activity.isEmpty {
                    Button {
                        activity = ""
                        checkUnsavedChanges()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(16)
            .background(Color.black.opacity(0.2))
            .clipShape(Capsule())
        }
    }

    // MARK: - Audience Input

    private var audienceInputSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(
                "Who are you looking to connect with?"
            )

            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.white.opacity(0.7))

                TextField(
                    "e.g. adventurers",
                    text: $connectionTarget
                )
                .font(.system(size: 18))
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
                .onChange(of: connectionTarget) {
                    checkUnsavedChanges()
                }

                if !connectionTarget.isEmpty {
                    Button {
                        connectionTarget = ""
                        checkUnsavedChanges()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(16)
            .background(Color.black.opacity(0.2))
            .clipShape(Capsule())
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
                        experienceType = type
                        checkUnsavedChanges()
                    } label: {
                        if experienceType == type {
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
                    Image(systemName: "tag.fill")
                        .foregroundColor(.white.opacity(0.7))

                    Text(experienceType.isEmpty ? "Select Type" : experienceType)
                        .font(.system(size: 18))
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(16)
                .background(Color.black.opacity(0.2))
                .clipShape(Capsule())
            }
        }
    }

    // MARK: - Capacity

    private var capacitySection: some View {
        
        return VStack(alignment: .leading, spacing: 16) {
            sectionTitle("With how many people?")
            
            if (maxPeople < 2){
                Text("one person")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            else if (minPeople == 0){
                Text("up to \(Int(maxPeople)) people")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            else if (Int(minPeople) == Int(maxPeople)){
                Text("\(Int(maxPeople)) people")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            else {
                Text("\(Int(minPeople)) to \(Int(maxPeople)) people")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            
            HStack(spacing: 14) {
                Image(systemName: "person.fill")
                    .foregroundColor(.white.opacity(0.7))
                
                // Assuming RangeSlider can adopt standard colors, else wrap it as needed
                RangeSlider(
                    lowerValue: $minPeople,
                    upperValue: $maxPeople,
                    bounds: 1...20
                )
                .padding(.vertical)
                
                Image(systemName: "person.3.fill")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    // MARK: - Days

    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Which days work for you?")

            HStack(spacing: 6) {
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
                                    size: 13,
                                    weight: .bold
                                )
                            )
                            .foregroundColor(
                                selectedDays.contains(day)
                                ? bgOrange
                                : .white
                            )
                            .frame(
                                maxWidth: .infinity
                            )
                            .frame(height: 44)
                            .background(
                                selectedDays.contains(day)
                                ? Color.white
                                : Color.black.opacity(0.2)
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Time

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("At this time:")

            HStack {
                
                ZStack {
                    DatePicker(
                        "",
                        selection: $time,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .colorInvert()
                    .colorMultiply(.white)
                    .onChange(of: time) {
                        checkUnsavedChanges()
                    }
                }
                
                Spacer()
                
            }
            .padding(16)
            .background(Color.black.opacity(0.2))
            .clipShape(Capsule())
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
    
    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Where will it happen?")

            HStack(spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.white.opacity(0.7))

                TextField(
                    "Location (Optional)",
                    text: $location
                )
                .font(.system(size: 18))
                .foregroundColor(.white)
                .onChange(of: location) {
                    checkUnsavedChanges()
                }

                if !location.isEmpty {
                    Button {
                        location = ""
                        checkUnsavedChanges()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(16)
            .background(Color.black.opacity(0.2))
            .clipShape(Capsule())
        }
    }

    // MARK: - Preview

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Preview:")

            previewText
                .font(
                    .system(
                        size: 26,
                        weight: .bold
                    )
                )
                .lineSpacing(7)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(30)
                .background(
                    Color.black.opacity(0.3)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 24
                    )
                )

            Text("Looking good?")
                .font(.subheadline.weight(.bold))
                .foregroundColor(
                    .white.opacity(0.8)
                )
                .frame(maxWidth: .infinity)
        }
    }

    private var previewText: Text {
            let hostName = authManager.profile?.full_name
                ?? authManager.profile?.username
                ?? "Someone"

            let safeActivity = activity.trimmingCharacters(in: .whitespaces).isEmpty
                ? "do something fun"
                : activity

            let safeTarget = connectionTarget.trimmingCharacters(in: .whitespaces).isEmpty
                ? "new people"
                : connectionTarget

            // Convert Doubles to Ints to remove the .0 decimals
            let minP = Int(minPeople)
            let maxP = Int(maxPeople)
            let peopleString = minP == maxP ? "\(maxP)" : "\(minP)-\(maxP)"

            // Stylized format
            return Text("""
                \(Text("\(hostName) ").foregroundColor(accentCyan))\
                \(Text("wants ").foregroundColor(.white))\
                \(Text("\(peopleString) ").foregroundColor(.yellow))\
                \(Text("\(safeTarget) ").foregroundColor(accentCyan))\
                \(Text("to \ngo ").foregroundColor(.white))\
                \(Text("\(safeActivity) ").foregroundColor(.green))\
                \(Text("with ").foregroundColor(.white))\
                \(styledDaysText)
                """)
        }

        private var styledDaysText: Text {
            let sortedDays = selectedDays.sorted { dayIndex($0) < dayIndex($1) }
            
            if sortedDays.isEmpty {
                return Text("anytime").foregroundColor(accentCyan)
            }
            if sortedDays.count == 1 {
                return Text(fullDayName(sortedDays[0])).foregroundColor(accentCyan)
            }
            if sortedDays.count == 2 {
                return Text(fullDayName(sortedDays[0])).foregroundColor(accentCyan)
                    + Text(" or ").foregroundColor(.white)
                    + Text(fullDayName(sortedDays[1])).foregroundColor(accentCyan)
            }
            
            var multiDayText = Text("")
            for (index, day) in sortedDays.enumerated() {
                if index == sortedDays.count - 1 {
                    multiDayText = multiDayText + Text("or ").foregroundColor(.white) + Text(fullDayName(day)).foregroundColor(accentCyan)
                } else {
                    multiDayText = multiDayText + Text("\(fullDayName(day)), ").foregroundColor(accentCyan)
                }
            }
            return multiDayText
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
                            .tint(.black)
                    } else {
                        Image(
                            systemName: "checkmark.circle.fill"
                        )

                        Text("Find my people")
                            .fontWeight(.bold)
                    }
                }
                .font(.title3)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
            }
            .disabled(isUploading)
            .opacity(isUploading ? 0.7 : 1)

            Button {
                eventManager.formResetTrigger = UUID()
                eventManager.selectedTab = 0
            } label: {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }

    // MARK: - Helper Views

    private func sectionTitle(
        _ text: String
    ) -> some View {
        Text(text)
            .font(.subheadline.weight(.bold))
            .foregroundColor(
                Color.white.opacity(0.9)
            )
            .padding(.bottom, -4)
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
            !activity.isEmpty
            || !connectionTarget.isEmpty
            || !location.isEmpty
            // || !description.isEmpty

        let hasOtherChanges =
            maxPeople != 5
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
        activity = ""
        connectionTarget = ""
        location = ""
        description = ""

        experienceType = "Explore"
        maxPeople = 5
        time = Date()
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
            // let imageURL = try await uploadEventImage()

            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short

            let timeString = timeFormatter.string(
                from: time
            )

            let trimmedTitle = activity.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            let trimmedAudience =
                connectionTarget.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let trimmedDescription =
                description.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let hostName =
                authManager.profile?.full_name
                ?? authManager.profile?.username
                ?? "Guest"

            let savedDescription = """
            Looking to connect with: \(trimmedAudience)

            \(trimmedDescription)
            """

            let newEvent = DetailedEvent(
                hostName: hostName,
                location: location,
                experienceType: experienceType.isEmpty ? "Explore" : experienceType,
                created_by: authManager.userID!,
                activity: activity,
                connectionTarget: connectionTarget,
                minPeople: minPeople,
                maxPeople: maxPeople,
                selectedDays: Array(selectedDays).sorted(),
                time: time,
                imgUrl: "", // Temp string since it's commented out
                description: "Description currently disabled",
                likeCount: 0,
                joinedCount: 1
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

    // MARK: - Image Loading (Commented Out)
    /*
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
    */

    // MARK: - Image Upload (Commented Out)
    /*
    private func uploadEventImage() async throws -> String? {
        guard let selectedImageData else {
            return nil
        }

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
    */
}

#Preview {
    ExperienceCreateView()
        .environmentObject(EventManager())
        .environmentObject(AuthManager())
}
