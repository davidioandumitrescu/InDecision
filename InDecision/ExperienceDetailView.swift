//
//  ExperienceDetailView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//
//
//import SwiftUI
//
//struct ExperienceDetailView: View {
//    var body: some View {
//        VStack{
//            BackButton
//        }
//    }
//}
//
//#Preview {
//    ExperienceDetailView()
//}

import SwiftUI

struct ExperienceDetailView: View {
    let event: DetailedEvent
    @EnvironmentObject var eventManager: EventManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 240)
                    .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray))
                    .clipShape(RoundedRectangle(cornerRadius: 20)).padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    LogisticRow(icon: "calendar", text: event.date)
                    LogisticRow(icon: "clock", text: event.time)
                    LogisticRow(icon: "mappin.and.ellipse", text: event.location)
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
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { eventManager.toggleSave(for: event.id) }) {
                    Image(systemName: eventManager.isSaved(eventId: event.id) ? "heart.fill" : "heart")
                        .foregroundColor(eventManager.isSaved(eventId: event.id) ? .red : .black)
                }
            }
        }
    }
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
