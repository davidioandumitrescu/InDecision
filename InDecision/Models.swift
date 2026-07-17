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
    var imgUrl: String? = nil
}

struct User: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var email: String
    var phonenumber: String
    var gender: String
}
