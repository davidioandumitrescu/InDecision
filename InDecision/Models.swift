//
//  Models.swift
//  InDecision
//
//  Created by Tracy on 17/7/2026.
//

import SwiftUI

enum EventStatus: String, CaseIterable, Codable {
    case solid = "Solid"
    case proposed = "Proposed"
}

// The main Event structure
struct DetailedEvent: Identifiable, Codable {
    var id: String = UUID().uuidString
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
}


// The Users structure

struct User: Identifiable, Hashable{
    let id = UUID()
    var name: String
    var surname: String
    var bio: String
    var favouriteColor: Color = .blue
    var email: String
    var password: String
    var isLoggedIn: Bool = false
    var isLoggedOut: Bool { !isLoggedIn }
}


