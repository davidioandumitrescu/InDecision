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
    var created_by: UUID
    
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
    /// false = Proposed (0 in DB), true = Solid (1 in DB)
    var isSolid: Bool = false
    
    // MARK: - Counters
    var likeCount: Int
    var joinedCount: Int
    
    // MARK: - Computed Logic
    
    var generatedTitle: String {
        "\(hostName) wants \(Int(minPeople))-\(Int(maxPeople)) \(connectionTarget) to go \(activity) with \(formattedDaysString)"
    }
    
    private var formattedDaysString: String {
        if selectedDays.isEmpty { return "anytime" }
        if selectedDays.count == 1 { return selectedDays[0] }
        if selectedDays.count == 2 { return "\(selectedDays[0]) or \(selectedDays[1])" }
        
        let allButLast = selectedDays.dropLast().joined(separator: ", ")
        return "\(allButLast), or \(selectedDays.last!)"
    }
    
    var stylizedPreview: Text {
//            Text("""
//            \(Text("\(hostName) ").foregroundColor(.blue))\
//            \(Text("wants ").foregroundColor(.black))\
//            \(Text("\(minPeople)-\(maxPeople) ").foregroundColor(.orange))\
//            \(Text("\(connectionTarget) ").foregroundColor(.blue))\
//            \(Text("to \ngo ").foregroundColor(.black))\
//            \(Text("\(activity) ").foregroundColor(.green))\
//            \(Text("with ").foregroundColor(.black))\
//            \(styledDaysText)
//            """)
        Text("\(hostName) wants \(Int(minPeople))-\(Int(maxPeople)) \(connectionTarget) to \ngo \(activity) with \(formattedDaysString)")
        }
    
    private var styledDaysText: Text {
        if selectedDays.isEmpty {
            return Text("anytime").foregroundColor(.blue)
        }
        if selectedDays.count == 1 {
            return Text(selectedDays[0]).foregroundColor(.blue)
        }
        if selectedDays.count == 2 {
            return Text(selectedDays[0]).foregroundColor(.blue)
                + Text(" or ").foregroundColor(.black)
                + Text(selectedDays[1]).foregroundColor(.blue)
        }
        
        var multiDayText = Text("")
        for (index, day) in selectedDays.enumerated() {
            if index == selectedDays.count - 1 {
                multiDayText = multiDayText + Text("or ").foregroundColor(.black) + Text(day).foregroundColor(.blue)
            } else {
                multiDayText = multiDayText + Text("\(day), ").foregroundColor(.blue)
            }
        }
        return multiDayText
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
    }
}


struct Profile: Identifiable, Codable {
    let id: UUID
    let username: String
    let full_name: String?
}

struct SavedEvent: Codable {
    let userID: UUID
    let eventID: UUID

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case eventID = "event_id"
    }
}
