//
//  ExperienceView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI

// MARK: - 1. THE REVERSED STAGGERED SHAPE
struct StaggeredBottomShape: Shape {
    var steps: Int = 3
    var stepHeight: CGFloat = 30
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stepWidth = rect.width / CGFloat(steps)
        
        // 1. Start top-left
        path.move(to: CGPoint(x: 0, y: 0))
        // 2. Line to top-right
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        
        // 3. Line down the right side
        let highestPointOnRight = rect.height - (CGFloat(steps - 1) * stepHeight)
        path.addLine(to: CGPoint(x: rect.width, y: highestPointOnRight))
        
        // 4. Draw the steps going backwards from right to left, dropping DOWN
        for i in (0..<steps).reversed() {
            let currentX = CGFloat(i) * stepWidth
            let currentY = rect.height - (CGFloat(i) * stepHeight)
            
            // Horizontal line going left
            path.addLine(to: CGPoint(x: currentX, y: currentY))
            
            // Vertical line going down
            if i != 0 {
                let nextStepDownY = rect.height - (CGFloat(i - 1) * stepHeight)
                path.addLine(to: CGPoint(x: currentX, y: nextStepDownY))
            }
        }
        
        // 5. Close the path up the left side
        path.closeSubpath()
        return path
    }
}

// MARK: - 2. THE CARD VIEW
struct StaggeredEventCard: View {
    var event: DetailedEvent
    var bgColor: Color
    var nextColor: Color
    
    var stepHeight: CGFloat = 30
    var steps: Int = 3
    var isFirstItem: Bool = false
    
    var body: some View {
        let overlapAmount = stepHeight * CGFloat(steps - 1)
        let remainingPeople = max(0, Int(event.maxPeople) - event.joinedCount)
        
        VStack(alignment: .leading, spacing: 16) {
            Text("\(remainingPeople) more people to reach goal!")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
            NavigationLink(destination: ExperienceDetailView(event: event, bgColor: bgColor, nextColor: nextColor)) {
                Text(event.generatedTitle)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .lineSpacing(4)
            }
            .buttonStyle(PlainButtonStyle())
            // Tags and Icons row
            HStack(spacing: 12) {
                // Proposed / Solid Tag
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
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill").foregroundColor(.red)
                    Text("\(event.likeCount)").foregroundColor(.black.opacity(0.6))
                }.font(.subheadline.bold())
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.black.opacity(0.6))
                    Text("\(event.joinedCount)").foregroundColor(.black.opacity(0.6))
                }.font(.subheadline.bold())
            }
        }
        .padding(.top, isFirstItem ? 200 : 48 + overlapAmount)
        .padding(.horizontal, 32)
        .padding(.bottom, 60 + overlapAmount)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bgColor)
        .clipShape(StaggeredBottomShape(steps: steps, stepHeight: stepHeight))
    }
}

// MARK: - 3. THE MAIN LIST
struct ExperienceListView: View {
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var authManager: AuthManager
    
    // MARK: - Filter States
    @State private var searchText = ""
    @State private var selectedFilter = 0
    @State private var typeFilter: String = "All"
    
    let experienceTypes = ["All", "Teach", "Demonstrate", "StoryTell", "Build", "Mentor", "Explore", "Discuss", "Practice"]
    
    let palette: [Color] = [.teal, .green, .yellow, .orange]
    let stepCount = 3
    let stepHeight: CGFloat = 30
    
    // MARK: - Filter Logic (Now uses eventManager.events!)
    var filterEvents: [DetailedEvent] {
        eventManager.events.filter { event in
            let matchesSearch = searchText.isEmpty || event.generatedTitle.localizedCaseInsensitiveContains(searchText) || event.hostName.localizedCaseInsensitiveContains(searchText)
            
            let matchesSegment: Bool
            if selectedFilter == 1 { matchesSegment = !event.isSolid }
            else if selectedFilter == 2 { matchesSegment = event.isSolid }
            else { matchesSegment = true }
            
            let matchesType = (typeFilter == "All") || (event.experienceType == typeFilter)
            
            return matchesSearch && matchesSegment && matchesType
        }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    
                    // MARK: - THE BACKGROUND SCROLLING LIST
                    ScrollView(.vertical, showsIndicators: false) {
                        let overlapAmount = stepHeight * CGFloat(stepCount - 1)
                        
                        if filterEvents.isEmpty {
                            VStack(spacing: 16) {
                                Text("No events match your search.")
                                    .foregroundColor(.gray)
                                
                                // Show a loading indicator if events are still fetching
                                if eventManager.events.isEmpty && eventManager.errorMessage.isEmpty {
                                    ProgressView()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 200)
                        } else {
                            VStack(spacing: -overlapAmount) {
                                ForEach(Array(filterEvents.enumerated()), id: \.element.id) { index, event in
                                    StaggeredEventCard(
                                        event: event,
                                        bgColor: palette[index % palette.count],
                                        nextColor: palette[(index + 1) % palette.count],
                                        stepHeight: stepHeight,
                                        steps: stepCount,
                                        isFirstItem: index == 0
                                    )
                                    .zIndex(Double(filterEvents.count - index))
                                }
                            }
                            .padding(.bottom, overlapAmount)
                            
                            // MARK: - BOTTOM SUGGESTION PROMPT
                            Button(action: {
                                // Jumps to your Create Tab via EventManager!
                                eventManager.selectedTab = 1
                            }) {
                                Text("Can't find anything interesting?\n**Suggest something.**")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.96))
                            }
                            .padding(.bottom, 60)
                        }
                    }
                    .background(palette.first?.ignoresSafeArea())
                    .ignoresSafeArea(edges: .top)
                    
                    // MARK: - THE FOREGROUND PINNED HEADER
                    VStack(spacing: 16) {
                        
                        // 1. Search Bar & Profile Button
                        HStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass").foregroundColor(.gray).font(.system(size: 20))
                                TextField("Explore", text: $searchText).font(.system(size: 18))
                                Image(systemName: "mic").foregroundColor(.gray).font(.system(size: 20))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            // Filter Dropdown Button
                            Menu {
                                ForEach(experienceTypes, id: \.self) { type in
                                    Button(action: { typeFilter = type }) {
                                        if typeFilter == type {
                                            Label(type, systemImage: "checkmark")
                                        } else {
                                            Text(type)
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.black)
                                    .frame(width: 50, height: 50)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            // Profile Button
                            NavigationLink(destination: ProfileDestinationView()) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 2. Segmented Control
                        Picker("Filter", selection: $selectedFilter) {
                            Text("All").tag(0)
                            Text("Proposed").tag(1)
                            Text("Solid").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        // 3. Active Filter Indicator
                        if typeFilter != "All" {
                            HStack {
                                Text("Filtered by: **\(typeFilter)**")
                                    .font(.caption)
                                    .foregroundColor(.black)
                                Spacer()
                                Button(action: { typeFilter = "All" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.black.opacity(0.6))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .zIndex(1)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.ignoresSafeArea())
                .toolbar(.hidden, for: .navigationBar)
            }
        }
        // FETCH DATA WHEN THE VIEW LOADS
        .task {
            // Only fetch if empty to prevent unnecessary database calls every time the view appears
            //if eventManager.events.isEmpty {
                await eventManager.loadEvents()
                await eventManager.loadSavedEvents(for: authManager.userID)
                await eventManager.loadJoinedEvents(for: authManager.userID)
            //}
        }
    }
}
