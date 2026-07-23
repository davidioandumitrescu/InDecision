////
////  ExperienceCreateView.swift
////  InDecision
////
////  Created by David-Ioan Dumitrescu on 16/7/2026.
////  Updated by Lisa on 20/7/2026.
//

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
    @State  var selectedDate: Date = Date.now
    @State  var time: Date = Date.now
    @State  var isSolid: Bool = false
    @State  var location: String = ""
    @State  var experienceType: String = ""
    @State  var description: String = ""
    
    @State  var showValidationError = false
    @State  var validationMessage = ""
    @State  var imgUrl = ""
    
    // MARK: - Theme Colors
    private let bgOrange = Color("ColorOrange")
    private let accentCyan = Color("AccentColor")
    
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
        
        
//        if selectedDays.isEmpty {
//            return false
//        }
        
        if isSolid {
            if location.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty {
                return false
            }
        } else {
            if selectedDays.isEmpty {
                return false
            }
        }
        
        return true
    }
    
    private func getValidationMessage() -> String {
        var missingFields: [String] = []
        
//        if activity.trimmingCharacters(
//            in: .whitespacesAndNewlines
//        ).isEmpty {
//            missingFields.append("Activity")
//        }

        if isSolid {
            if location.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty {
                missingFields.append("Location")
            }
        } else {
            if selectedDays.isEmpty {
                missingFields.append("Available day")
            }
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
                        
                        statusSection
                        
                        activityInputSection
                        
                        audienceInputSection
                        
                        experienceTypeSection
                        
                        capacitySection
                        
                        if isSolid {
                            solidDateSection
                        } else {
                            daysSection
                        }
                        
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
                Image("BloopLogo-Sml")
            }
            
            Spacer()
            
            
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - Event Status

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("What kind of event is this?")

            Picker("Event Status", selection: $isSolid) {
                Text("Proposed").tag(false)
                Text("Solid").tag(true)
            }
            .pickerStyle(.segmented)
            .onChange(of: isSolid) {
                checkUnsavedChanges()
            }
        }
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
    
    
    // MARK: - Solid Date

    private var solidDateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Which day?")

            DatePicker(
                "Select a date",
                selection: $selectedDate,
                in: Date.now...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(.white)
            .padding()
            .background(Color.black.opacity(0.2))
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
            .onChange(of: selectedDate) {
                checkUnsavedChanges()
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
            sectionTitle(isSolid ? "Where will it happen?" : "Where might it happen?")
            
            HStack(spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.white.opacity(0.7))
                
                TextField(
                    isSolid ? "Location" : "Location(Optional)",
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
        let hostName =
        authManager.profile?.full_name
        ?? authManager.profile?.username
        ?? "Someone"
        
        let safeActivity =
        activity.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        ? "something fun"
        : activity
        
        let safeTarget =
        connectionTarget.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        ? "new people"
        : connectionTarget
        
        let safeLocation =
        location.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        ? "a location to be confirmed"
        : location
        
        let peopleString: String
        
        if maxPeople < 2 {
            peopleString = "one"
        } else if minPeople == 0 {
            peopleString = "up to \(Int(maxPeople))"
        } else if minPeople == maxPeople {
            peopleString = "\(Int(maxPeople))"
        } else {
            peopleString =
            "\(Int(minPeople))-\(Int(maxPeople))"
        }
        
        if isSolid {
            return Text("\(hostName) ")
                .foregroundColor(accentCyan)
            
            + Text("is hosting ")
                .foregroundColor(.white)
            
            + Text("\(safeActivity) ")
                .foregroundColor(.green)
            
            + Text("for ")
                .foregroundColor(.white)
            
            + Text("\(peopleString) ")
                .foregroundColor(.yellow)
            
            + Text("\(safeTarget) ")
                .foregroundColor(accentCyan)
            
            + Text("on ")
                .foregroundColor(.white)
            
            + Text("\(formattedSelectedDate) ")
                .foregroundColor(accentCyan)
            
            + Text("at ")
                .foregroundColor(.white)
            
            + Text("\(formattedTime) ")
                .foregroundColor(.yellow)
            
            + Text("at ")
                .foregroundColor(.white)
            
            + Text(safeLocation)
                .foregroundColor(.green)
        }
        
        return Text("\(hostName) ")
            .foregroundColor(accentCyan)
        
        + Text("wants ")
            .foregroundColor(.white)
        
        + Text("\(peopleString) ")
            .foregroundColor(.yellow)
        
        + Text("\(safeTarget) ")
            .foregroundColor(accentCyan)
        
        + Text("to go ")
            .foregroundColor(.white)
        
        + Text("\(safeActivity) ")
            .foregroundColor(.green)
        
        + Text("on ")
            .foregroundColor(.white)
        
        + styledDaysText
    }
    
    private var styledDaysText: Text {
        let sortedDays = selectedDays.sorted {
            dayIndex($0) < dayIndex($1)
        }

        if sortedDays.isEmpty {
            return Text("anytime")
                .foregroundColor(accentCyan)
        }

        if sortedDays.count == 1 {
            return Text(fullDayName(sortedDays[0]))
                .foregroundColor(accentCyan)
        }

        if sortedDays.count == 2 {
            return Text(fullDayName(sortedDays[0]))
                .foregroundColor(accentCyan)
            + Text(" or ")
                .foregroundColor(.white)
            + Text(fullDayName(sortedDays[1]))
                .foregroundColor(accentCyan)
        }

        var result = Text("")

        for (index, day) in sortedDays.enumerated() {
            if index == sortedDays.count - 1 {
                result = result
                + Text("or ")
                    .foregroundColor(.white)
                + Text(fullDayName(day))
                    .foregroundColor(accentCyan)
            } else {
                result = result
                + Text("\(fullDayName(day)), ")
                    .foregroundColor(accentCyan)
            }
        }

        return result
    }
    
    
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
//            // Stylized format
//            return Text("""
//                \(Text("\(hostName) ").foregroundColor(accentCyan))\
//                \(Text("wants ").foregroundColor(.white))\
//                \(Text("\(peopleString) ").foregroundColor(.yellow))\
//                \(Text("\(safeTarget) ").foregroundColor(accentCyan))\
//                \(Text("to \ngo ").foregroundColor(.white))\
//                \(Text("\(safeActivity) ").foregroundColor(.green))\
//                \(Text("with ").foregroundColor(.white))\
//                \(styledDaysText)
//                """)
//        }
//
//        private var styledDaysText: Text {
//            let sortedDays = selectedDays.sorted { dayIndex($0) < dayIndex($1) }
//            
//            if sortedDays.isEmpty {
//                return Text("anytime").foregroundColor(accentCyan)
//            }
//            if sortedDays.count == 1 {
//                return Text(fullDayName(sortedDays[0])).foregroundColor(accentCyan)
//            }
//            if sortedDays.count == 2 {
//                return Text(fullDayName(sortedDays[0])).foregroundColor(accentCyan)
//                    + Text(" or ").foregroundColor(.white)
//                    + Text(fullDayName(sortedDays[1])).foregroundColor(accentCyan)
//            }
//            
//            var multiDayText = Text("")
//            for (index, day) in sortedDays.enumerated() {
//                if index == sortedDays.count - 1 {
//                    multiDayText = multiDayText + Text("or ").foregroundColor(.white) + Text(fullDayName(day)).foregroundColor(accentCyan)
//                } else {
//                    multiDayText = multiDayText + Text("\(fullDayName(day)), ").foregroundColor(accentCyan)
//                }
//            }
//            return multiDayText
//        }

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
    
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"

        return formatter.string(from: selectedDate)
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

        isSolid = false
        selectedDate = Date.now
        
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
        guard !isUploading else { return }
        
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
                created_by: authManager.userID,
                activity: activity,
                connectionTarget: connectionTarget,
                minPeople: minPeople,
                maxPeople: maxPeople,
                selectedDays: isSolid
                    ? [formattedSelectedDate]
                    : Array(selectedDays),
                time: time,
                imgUrl: "", // Temp string since it's commented out
                description: "Description currently disabled",
                isSolid: isSolid,
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
