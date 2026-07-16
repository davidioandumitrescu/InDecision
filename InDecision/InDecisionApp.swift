//
//  InDecisionApp.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI

@main
struct InDecisionApp: App {
    var body: some Scene {
        WindowGroup {
            TabView{
                ExperienceView()
                    .tabItem {
                        Label("Experience", systemImage: "person.3.fill")
                    }
                ExperienceCreateView()
                    .tabItem {
                        Label("Create", systemImage: "plus")
                    }
                ExperienceSavedView()
                    .tabItem {
                        Label("Saved", systemImage: "heart")
                    }
            }
        }
    }
}
