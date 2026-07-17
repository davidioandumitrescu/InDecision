//
//  InDecisionApp.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI

@main
struct InDecisionApp: App {
    @StateObject private var eventManager = EventManager()
    
    @State private var showDiscardAlert = false
    @State private var pendingTab = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: Binding(
                get: { eventManager.selectedTab },
                set: { newTab in
                    if eventManager.selectedTab == 1 && newTab != 1 && eventManager.hasUnsavedChanges {
                        // They are trying to leave the Create tab! Show alert.
                        pendingTab = newTab
                        showDiscardAlert = true
                    } else {
                        // Safe to switch
                        eventManager.selectedTab = newTab
                    }
                }
            )){
                    ExperienceListView()
                    .tabItem {
                        Label("Experience", systemImage: "person.3.fill")
                    }
                    .tag(0)
                NavigationStack{
                    ExperienceCreateView()
                }
                    .tabItem {
                        Label("Create", systemImage: "plus")
                    }
                    .tag(1)
                NavigationStack{
                    ExperienceSavedView()
                }
                    .tabItem {
                        Label("Saved", systemImage: "heart")
                    }
                    .tag(2)
            }.alert("Discard your event?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) {
                    eventManager.formResetTrigger = UUID()
                    eventManager.hasUnsavedChanges = false
                    eventManager.selectedTab = pendingTab
                }
                Button("Keep Editing", role: .cancel) {
                    // Does nothing, just dismisses the alert
                }
            } message: {
                Text("If you leave this tab, all your entered details will be lost.")
            }
            .environmentObject(eventManager)
        }
    }
}
