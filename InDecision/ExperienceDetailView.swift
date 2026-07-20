//
//  ExperienceDetailView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI

//struct ExperienceDetailView: View {
//    // Make sure this matches your newly renamed model
//    var event: DetailedEvent
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//                
//                // 1. THE HERO TEXT (Uses the colorful stylized text)
//                event.stylizedPreview
//                    .font(.system(size: 32, weight: .bold))
//                    .lineSpacing(4)
//                    .padding(.bottom, 8)
//                
//                // 2. TAGS
//                HStack(spacing: 12) {
//                    Text(event.isSolid ? "Solid" : "Proposed")
//                        .font(.subheadline.bold())
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                        // Make solid green, proposed orange
//                        .background(event.isSolid ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
//                        .foregroundColor(event.isSolid ? .green : .orange)
//                        .clipShape(Capsule())
//                    
//                    Text(event.experienceType)
//                        .font(.subheadline.bold())
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                        .background(Color.blue.opacity(0.1))
//                        .foregroundColor(.blue)
//                        .clipShape(Capsule())
//                }
//                
//                Divider()
//                
//                // 3. DETAILS LIST
//                VStack(alignment: .leading, spacing: 20) {
//                    DetailRow(icon: "person.fill", title: "Host", value: event.created_by.uuidString)
//                    DetailRow(icon: "mappin.and.ellipse", title: "Location", value: event.location)
//                    DetailRow(icon: "calendar", title: "Days", value: event.selectedDays.isEmpty ? "Anytime" : event.selectedDays.joined(separator: ", "))
//                    //DetailRow(icon: "clock.fill", title: "Time", value: event.time)
//                    DetailRow(icon: "person.2.fill", title: "Looking For", value: event.connectionTarget)
//                }
//                
//                Divider()
//                
//                // 4. STATS ROW
//                HStack(spacing: 40) {
//                    StatBox(title: "Joined", value: "\(event.joinedCount) / \(event.maxPeople)")
//                    StatBox(title: "Likes", value: "\(event.likeCount)")
//                    StatBox(title: "Min. Needed", value: "\(event.minPeople)")
//                }
//                .frame(maxWidth: .infinity, alignment: .center)
//                .padding(.top, 8)
//                
//                Spacer()
//            }
//            .padding(24)
//        }
//        .navigationTitle("Event Details")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - HELPER VIEWS
//// These keep the main view clean and easy to read
//
//struct DetailRow: View {
//    var icon: String
//    var title: String
//    var value: String
//    
//    var body: some View {
//        HStack(spacing: 16) {
//            Image(systemName: icon)
//                .foregroundColor(.gray)
//                .font(.system(size: 20))
//                .frame(width: 24)
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                Text(value)
//                    .font(.body)
//                    .fontWeight(.medium)
//            }
//        }
//    }
//}
//
//struct StatBox: View {
//    var title: String
//    var value: String
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            Text(value)
//                .font(.title2)
//                .bold()
//            Text(title)
//                .font(.caption)
//                .foregroundColor(.gray)
//        }
//    }
//}

struct ExperienceDetailView: View {
    let event: DetailedEvent
    
    // Dependencies
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.dismiss) var dismiss
    
    // UI State
    @State private var isJoined: Bool = false
    @State private var attendees: [Profile] = []
    @State private var isLoadingAttendees: Bool = true
    
    // Colors passed from list view
    var bgColor: Color
    var nextColor: Color
    
    // Theme Constants
    private let buttonPurple = Color(red: 0.45, green: 0.35, blue: 0.95)
    
    var body: some View {
        ZStack {
            // 1. Background Layers
            bgColor.ignoresSafeArea()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        nextColor.frame(width: 125, height: 60)
                        nextColor.frame(width: 250, height: 60)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            
            // 2. Core Content Layer
            VStack(alignment: .leading, spacing: 24) {
                headerBar
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        Text("\(Int(event.maxPeople) - event.joinedCount) more people to reach goal!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.top, 10)
                        
                        event.stylizedPreview
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .lineSpacing(6)
                        
                        tagsSection
                        infoRowsSection
                        socialStatsBar
                        attendeesAvatersSection
                        
                        Spacer(minLength: 40)
                        actionButtonsArea
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            // Placeholder: When you implement your DB fetch, uncomment this:
            // attendees = await eventManager.getAttendees(for: event.id)
            isLoadingAttendees = false
        }
    }
    
    // MARK: - Subsections
    
    private var headerBar: some View {
            HStack {
                // 1. The Custom Back Button
                Button(action: {
                    dismiss() // This safely takes you back to the list!
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                    }
                    .foregroundColor(.white)
                }
                
                Spacer()
                
                // 2. The Profile Button
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 10)
        }
    
    private var tagsSection: some View {
        HStack(spacing: 10) {
            Text(event.isSolid ? "Solid" : "Proposed")
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(event.isSolid ? Color.white.opacity(0.4) : Color.black.opacity(0.3))
                .clipShape(Capsule())
                .foregroundColor(.white)
            
            Text(event.experienceType)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.3))
                .clipShape(Capsule())
                .foregroundColor(.white)
            
        }
        .padding(.top)
    }
    
    private var infoRowsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "location.north.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                Text(event.location.isEmpty ? "Location undecided yet" : event.location)
                    .font(.system(size: 18))
                    .foregroundColor(.black.opacity(0.7))
            }
            HStack(spacing: 10) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                Text(event.time.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 18))
                    .foregroundColor(.black.opacity(0.7))
            }
        }
        .fontWeight(.medium)
    }
    
    private var socialStatsBar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "heart.circle")
                    .foregroundColor(.pink.opacity(0.7))
                    .font(.system(size: 24, weight: .bold))
                Text("\(event.likeCount)")
                    .foregroundColor(.black.opacity(0.7))
            }
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black.opacity(0.7))
                Text("\(event.joinedCount)")
                    .foregroundColor(.black.opacity(0.7))
            }
        }
        .font(.subheadline)
        .fontWeight(.bold)
    }
    
    private var attendeesAvatersSection: some View {
        HStack(spacing: 10) {
            if isLoadingAttendees {
                ProgressView().tint(.white)
            } else {
                // Placeholder loop - will show real data once eventManager.getAttendees is ready
                ForEach(attendees) { user in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 54, height: 54)
                }
            }
        }
    }
    
    private var actionButtonsArea: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isJoined.toggle()
                }
            }) {
                HStack {
                    Image(systemName: isJoined ? "checkmark.circle.fill" : "checkmark.circle")
                    Text(isJoined ? "You are going" : "Yes, I'm in!")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(isJoined ? buttonPurple : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(isJoined ? Color.white : buttonPurple)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            Button(action: {
                Task {
                await eventManager.toggleSave(for: event.id, userID: nil)
            }
            }) {
                Label("Save for later", systemImage: "heart.fill")
                    .font(Font.body.bold())
                    .foregroundColor(buttonPurple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: buttonPurple.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 50)
        }
    }
}
