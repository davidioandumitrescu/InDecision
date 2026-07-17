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
                HStack {
                    Text("My Experience")
                        .font(.title)
                        .bold() 
                    
                    Spacer()
                    
                    NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.black)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(savedEvents) { event in
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
                                        .foregroundColor(.primary)                                }
                            }
                            
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
    }
