//
//  ExperienceDetailView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI

struct ExperienceDetailView: View {
    // Make sure this matches your newly renamed model
    var event: DetailedEvent
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // 1. THE HERO TEXT (Uses the colorful stylized text)
                event.stylizedPreview
                    .font(.system(size: 32, weight: .bold))
                    .lineSpacing(4)
                    .padding(.bottom, 8)
                
                // 2. TAGS
                HStack(spacing: 12) {
                    Text(event.isSolid ? "Solid" : "Proposed")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        // Make solid green, proposed orange
                        .background(event.isSolid ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        .foregroundColor(event.isSolid ? .green : .orange)
                        .clipShape(Capsule())
                    
                    Text(event.experienceType)
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
                
                Divider()
                
                // 3. DETAILS LIST
                VStack(alignment: .leading, spacing: 20) {
                    DetailRow(icon: "person.fill", title: "Host", value: event.hostName)
                    DetailRow(icon: "mappin.and.ellipse", title: "Location", value: event.location)
                    DetailRow(icon: "calendar", title: "Days", value: event.selectedDays.isEmpty ? "Anytime" : event.selectedDays.joined(separator: ", "))
                    DetailRow(icon: "clock.fill", title: "Time", value: event.time)
                    DetailRow(icon: "person.2.fill", title: "Looking For", value: event.connectionTarget)
                }
                
                Divider()
                
                // 4. STATS ROW
                HStack(spacing: 40) {
                    StatBox(title: "Joined", value: "\(event.joinedCount) / \(event.maxPeople)")
                    StatBox(title: "Likes", value: "\(event.likeCount)")
                    StatBox(title: "Min. Needed", value: "\(event.minPeople)")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - HELPER VIEWS
// These keep the main view clean and easy to read

struct DetailRow: View {
    var icon: String
    var title: String
    var value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .font(.system(size: 20))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
    }
}

struct StatBox: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
