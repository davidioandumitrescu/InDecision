//
//  Models.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import Foundation

enum EventStatus: String, CaseIterable, Codable {
    case solid = "Solid"
    case proposed = "Proposed"
}

// The main Event structure
struct DetailedEvent: Identifiable, Codable {
    var id: UUID = UUID()
    var createdBy: UUID
    var title: String
    var status: EventStatus
    var hostName: String
    var location: String
    var date: String
    var time: String
    var description: String
    var experienceType: String
    var capacity: Double
    var contactEmail: String

    enum CodingKeys: String, CodingKey {
        case id
        case createdBy = "created_by"
        case title
        case status
        case hostName
        case location
        case date
        case time
        case description
        case experienceType
        case capacity
        case contactEmail
    }
}

struct User: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var email: String
    var phonenumber: String
    var gender: String
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
