//
//  ExperienceSavedView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI


struct ExperienceSavedView: View {
    
        @EnvironmentObject var eventManager: EventManager
        
        var savedEvents: [DetailedEvent] {
            eventManager.events.filter { eventManager.savedEventIDs.contains($0.id) }
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("My Experience")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(savedEvents) { event in
                            
                            // FIX: Wrapped the bubble in a NavigationLink
                            NavigationLink(destination: ExperienceDetailView(event: event)) {
                                VStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 70, height: 70)
                                        .overlay(Text(String(event.title.prefix(1))).font(.title).foregroundColor(.blue))
                                    
                                    Text(event.title)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .frame(width: 70)
                                        .foregroundColor(.primary) // Stops the text from turning standard link-blue
                                }
                            }
                            
                        }
                    }
                    .padding(.horizontal)
                }
                
                // FIX: This Spacer pushes the VStack to the absolute top of the screen
                Spacer()
            }
        }
    }
