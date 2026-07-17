//
//  ExperienceView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI

struct ExperienceListView: View {
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var authManager: AuthManager
        @State private var searchText = ""
        @State private var selectedFilter = 0 // 0: All, 1: Proposed, 2: Solid
        @State private var typeFilter: String = "All"
        
        let experienceTypes = ["All", "Teach", "Demonstrate", "StoryTell", "Build", "Mentor", "Explore", "Discuss", "Practice"]
        
        var filteredEvents: [DetailedEvent] {
            eventManager.events.filter { event in
                let matchesSearch = searchText.isEmpty || event.title.localizedCaseInsensitiveContains(searchText) || event.experienceType.localizedCaseInsensitiveContains(searchText)
                
                let matchesSegment: Bool
                if selectedFilter == 1 { matchesSegment = event.status == .proposed }
                else if selectedFilter == 2 { matchesSegment = event.status == .solid }
                else { matchesSegment = true }
                
                let matchesType = (typeFilter == "All") || (event.experienceType == typeFilter)
                
                return matchesSearch && matchesSegment && matchesType
            }
        }
        
        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // 1. CUSTOM SEARCH BAR & FILTER BUTTON
                        HStack(spacing: 12) {
                            // Search Field
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 20))
                                
                                TextField("Explore", text: $searchText)
                                    .font(.system(size: 18))
                                
                                Image(systemName: "mic")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 20))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            // Uses a subtle gray background to match your design
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                            
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
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            //Profile Button
                            NavigationLink(destination: ProfileDestinationView()) {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 44))
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.black)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // 2. SEGMENTED CONTROL (Proposed / Solid)
                        Picker("Filter", selection: $selectedFilter) {
                            Text("All").tag(0)
                            Text("Proposed").tag(1)
                            Text("Solid").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        // 3. ACTIVE FILTER INDICATOR
                        if typeFilter != "All" {
                            HStack {
                                Text("Filtered by: **\(typeFilter)**")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Spacer()
                                Button(action: { typeFilter = "All" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 4. EVENT CARDS
                        if filteredEvents.isEmpty {
                            Text("No events match your search.")
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                        } else {
                            ForEach(filteredEvents) { event in
                                NavigationLink(destination: ExperienceDetailView(event: event)) {
                                    EventCardView(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                //.navigationTitle("Experience")
                .task {
                    await authManager.refreshSession()
                    await eventManager.loadEvents()
                    await eventManager.loadSavedEvents(for: authManager.userID)
                }
            }
        }
    }
    struct EventCardView: View {
        let event: DetailedEvent
        @EnvironmentObject var eventManager: EventManager
        @EnvironmentObject var authManager: AuthManager
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                if event.status == .proposed {
                    Text("Proposed: \(event.title)").font(.headline)
                }
                
                HStack(alignment: .top, spacing: 12) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if event.status == .solid {
                            Text(event.title).font(.headline)
                        }
                        Text("**\(event.hostName)** \(event.description)")
                            .font(.subheadline).foregroundColor(.secondary).lineLimit(2)
                        
                        Text(event.experienceType)
                            .font(.caption).padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1)).foregroundColor(.blue).clipShape(Capsule())
                    }
                    Spacer()
                    
                    Image(systemName: eventManager.isSaved(eventId: event.id) ? "heart.fill" : "heart")
                        .foregroundColor(eventManager.isSaved(eventId: event.id) ? .red : .gray)
                        .font(.title3)
                        .padding(8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task {
                                await eventManager.toggleSave(for: event.id, userID: authManager.userID)
                            }
                        }
                }
            }
            .padding().background(Color.white).cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2).padding(.horizontal)
        }
    }
