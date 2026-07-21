//
//  ExperienceSavedView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI


struct ExperienceSavedView: View {
    
        @EnvironmentObject var eventManager: EventManager
        @EnvironmentObject var authManager: AuthManager
        
        var savedEvents: [DetailedEvent] {
            eventManager.events.filter { eventManager.savedEventIDs.contains($0.id) }
        }
            
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("My Experience")
                        .font(.title)
                        .bold()

                    Spacer()

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

                List(savedEvents) { event in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.generatedTitle)
                            .font(.headline)

                        Text(event.location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Label("\(event.likeCount)", systemImage: "heart.fill")
                            Label("\(event.joinedCount)", systemImage: "person.2.fill")
                        }
                        .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
            .task {
                await authManager.refreshSession()
                await eventManager.loadEvents()
                await eventManager.loadSavedEvents(for: authManager.userID)
            }
        }
    }
