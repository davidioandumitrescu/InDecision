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
                Spacer()
            }
        }
    }
