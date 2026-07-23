//
//  Models.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI

// The main Event structure
struct DetailedEvent: Identifiable, Codable {
    var id = UUID()
    
    // MARK: - Host Info
    var hostName: String = "Host"
    var location: String
    var experienceType: String
    var created_by: UUID?
    
    // MARK: - Semantic Form Fields
    var activity: String
    var connectionTarget: String
    var minPeople: Double
    var maxPeople: Double
    var selectedDays: [String]
    var time: Date
    var imgUrl: String
    var description: String
    
    // MARK: - Status
    var isSolid: Bool = false
    
    // MARK: - Counters
    var likeCount: Int = 0
    var joinedCount: Int = 0
    
    // MARK: - Supabase Relationship
    var saved_events: [SavedEventReference]? = nil
    
    // MARK: - Computed Logic
//    var generatedTitle: String {
//        if minPeople == maxPeople {
//            "\(hostName) wants \(Int(maxPeople)) \(connectionTarget) to go \(activity) with \(formattedDaysString)"
//
//        } else if minPeople == 0{
//            "\(hostName) wants up to \(Int(maxPeople)) \(connectionTarget) to go \(activity) with \(formattedDaysString)"
//
//        }
//        else {
//            "\(hostName) wants \(Int(minPeople))-\(Int(maxPeople)) \(connectionTarget) to go \(activity) with \(formattedDaysString)"
//        }
//    }
    
    var generatedTitle: String {
        let peopleText: String

        if maxPeople < 2 {
            peopleText = "one \(connectionTarget)"
        } else if minPeople == 0 {
            peopleText = "up to \(Int(maxPeople)) \(connectionTarget)"
        } else if minPeople == maxPeople {
            peopleText = "\(Int(maxPeople)) \(connectionTarget)"
        } else {
            peopleText =
                "\(Int(minPeople))-\(Int(maxPeople)) \(connectionTarget)"
        }

        if isSolid {
            let eventDate =
                selectedDays.first ?? "a confirmed date"

            return """
            \(hostName) is hosting \(activity) for \(peopleText) on \(eventDate) at \(formattedTimeString) at \(location)
            """
        } else {
            return """
            \(hostName) wants \(peopleText) to go \(activity) on \(formattedDaysString)
            """
        }
    }

    private var formattedDaysString: String {
        if selectedDays.isEmpty {
            return "any day"
        }

        if selectedDays.count == 1 {
            return selectedDays[0]
        }

        if selectedDays.count == 2 {
            return "\(selectedDays[0]) or \(selectedDays[1])"
        }
        
        if selectedDays.count > 6 {
            return "any day"
        }

        guard let lastDay = selectedDays.last else {
            return "any day"
        }

        let allButLast = selectedDays
            .dropLast()
            .joined(separator: ", ")

        return "\(allButLast), or \(lastDay)"
    }
    
    private var formattedTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        return formatter.string(from: time)


//     private var formattedDaysString: String {
//         if selectedDays.isEmpty { return "any day!" }
//         if selectedDays.count == 1 { return selectedDays[0] }
//         if selectedDays.count == 2 { return "\(selectedDays[0]) or \(selectedDays[1])" }
//         if selectedDays.count > 6 {return "any day!"}
        
//         let allButLast = selectedDays.dropLast().joined(separator: ", ")
//         return "\(allButLast), or \(selectedDays.last!)"

    }
    
    var stylizedPreview: Text {
        Text(generatedTitle)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case hostName = "host_name"
        case location
        case experienceType = "experience_type"
        case created_by
        case activity
        case connectionTarget = "connection_target"
        case minPeople = "min_people"
        case maxPeople = "max_people"
        case selectedDays = "selected_days"
        case time
        case imgUrl = "img_url"
        case description
        case isSolid = "is_solid"
        case likeCount = "like_count"
        case joinedCount = "joined_count"
        case saved_events
    }
}

struct SavedEventReference: Codable {
    let id: UUID?
}

struct Profile: Identifiable, Codable {
    let id: UUID
    let username: String
    let full_name: String?
    let avatar_url: String?
    let interests: [String]?
}

struct SavedEvent: Codable {
    let userID: UUID
    let eventID: UUID

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case eventID = "event_id"
    }
}

struct JoinedEvent: Codable {
    let userID: UUID
    let eventID: UUID

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case eventID = "event_id"
    }
}
