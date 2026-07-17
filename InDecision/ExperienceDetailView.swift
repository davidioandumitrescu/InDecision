//
//  ExperienceDetailView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI

struct ExperienceDetailView: View {
    let event: DetailedEvent
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // CUSTOM NAVIGATION BAR
                HStack {
                    // 1. Custom Back Button
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44) // Nice large touch target
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    // 2. Dynamic Title
                    Text(event.title)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // 3. Perfect Profile Button
                    NavigationLink(destination: ProfileDestinationView()) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 38)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 240)
                    .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray))
                    .clipShape(RoundedRectangle(cornerRadius: 20)).padding(.horizontal)
                
                HStack(alignment: .center) {
                    Text("In \(event.location)")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text(event.date)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6)) // Light gray background
                        .clipShape(Capsule())
                    Button(action: { eventManager.toggleSave(for: event.id) }) {
                        Image(systemName: eventManager.isSaved(eventId: event.id) ? "heart.fill" : "heart")
                            .font(.system(size: 24))
                            .foregroundColor(eventManager.isSaved(eventId: event.id) ? .red : .blue)
                            .padding(.leading, 8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    LogisticRow(icon: "clock", text: event.time)
                    LogisticRow(icon: "tag", text: event.experienceType)
                }.padding(.horizontal)
                
                Divider().padding(.horizontal)
                
                
                HStack {
                    Circle().fill(Color.gray.opacity(0.4)).frame(width: 48, height: 48)
                        .overlay(Text(String(event.hostName.prefix(1))).fontWeight(.bold))
                    VStack(alignment: .leading) {
                        Text(event.hostName).font(.headline)
                        Text(event.contactEmail).font(.subheadline).foregroundColor(.blue)
                    }
                }.padding(.horizontal)
                
                if event.capacity > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Capacity")
                            .font(.headline)
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.gray)
                            Text("Max \(Int(event.capacity)) people")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("About").font(.headline).padding(.top, 8)
                    Text(event.description).foregroundColor(.secondary)
                }.padding(.horizontal)
                
                Spacer()
            }.padding(.top, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    struct LogisticRow: View {
        let icon: String; let text: String
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon).frame(width: 24).foregroundColor(.blue)
                Text(text).font(.subheadline)
            }
        }
    }
}

