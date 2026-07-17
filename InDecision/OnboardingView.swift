//
//  OnboardingView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 17/7/2026.
//

import SwiftUI
import Combine

struct OnboardingView: View {
    @EnvironmentObject var eventManager: EventManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    @State private var currentIndex = 0
    
    // Cycles every 4 seconds. You can adjust this duration.
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - HEADER
                HStack {
                    Image(systemName: "person.3.fill")
                        .font(.title)
                    
                    Text("Bloop")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                }
                .padding(.horizontal, 20) // Pushed further left
                .padding(.top, 16)
                
                Spacer()
                
                // MARK: - ANIMATED TEXT AREA
                ZStack(alignment: .leading) {
                    if currentIndex == 0 {
                        phraseOne
                            .transition(.opacity)
                            .id(0)
                    } else if currentIndex == 1 {
                        phraseTwo
                            .transition(.opacity)
                            .id(1)
                    } else {
                        phraseThree
                            .transition(.opacity)
                            .id(2)
                    }
                }
                .padding(.horizontal, 20) // Pushed further left
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.easeInOut(duration: 1.0), value: currentIndex)
                
                Spacer()
                Spacer() // Added a second spacer to push the buttons further down
                
                // MARK: - ACTION BUTTONS
                VStack(spacing: 16) {
                    
                    // 1. Find things to do -> Enters App (Tab 0)
                    Button(action: {
                        eventManager.selectedTab = 0
                        hasSeenOnboarding = true
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Find things to do")
                        }
                        .font(.title3) // Made text bigger
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20) // Made button taller
                        .background(Color.black)
                        .clipShape(Capsule())
                    }
                    
                    // 2. Start something new -> Enters App (Tab 1)
                    Button(action: {
                        eventManager.selectedTab = 1
                        hasSeenOnboarding = true
                    }) {
                        HStack {
                            Image(systemName: "text.badge.plus")
                            Text("Start something new")
                        }
                        .font(.title3) // Made text bigger
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20) // Made button taller
                        .background(Color(red: 0.4, green: 0.35, blue: 0.96))
                        .clipShape(Capsule())
                    }
                    
                    // 3. I'm not sure -> Slides to InfoView
                    NavigationLink(destination: InfoView()) {
                        HStack(spacing: 6) {
                            Image(systemName: "questionmark.circle")
                            Text("I'm not sure")
                        }
                        .font(.headline) // Increased from subheadline
                        .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.96))
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 48) // Pushed slightly closer to the bottom edge
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onReceive(timer) { _ in
                // Cycle through the 3 phrases
                currentIndex = (currentIndex + 1) % 3
            }
        }
    }
    
    // MARK: - TEXT VARIATIONS
    
    // Variation 1
    var phraseOne: some View {
        Text("""
        \(Text("I want \n").foregroundColor(.black))\
        \(Text("people").foregroundColor(.blue).underline())\
        \(Text(" to \n").foregroundColor(.black))\
        \(Text("share").foregroundColor(.blue).underline())\
        \(Text(" this \nwith.").foregroundColor(.black))
        """)
        .font(.system(size: 44, weight: .bold, design: .default)) // Dropped to 44 to ensure it doesn't accidentally wrap weirdly on smaller phones
        .lineSpacing(4)
        .multilineTextAlignment(.leading)
    }
    
    // Variation 2
    var phraseTwo: some View {
        Text("""
        \(Text("Dan ").foregroundColor(.blue))\
        \(Text("wants \n").foregroundColor(.black))\
        \(Text("2-6 ").foregroundColor(.orange).underline(true, color: .orange))\
        \(Text("people").foregroundColor(.blue).underline(true, color: .blue))\
        \(Text(" to \n").foregroundColor(.black))\
        \(Text("do ").foregroundColor(.blue).underline(true, color: .blue))\
        \(Text("tai-chi ").foregroundColor(.green))\
        \(Text("with \ntomorrow").foregroundColor(.black))
        """)
        .font(.system(size: 44, weight: .bold, design: .default))
        .lineSpacing(4)
        .multilineTextAlignment(.leading)
    }
    
    // Variation 3
    var phraseThree: some View {
        Text("""
        \(Text("I'd love \nto ").foregroundColor(.black))\
        \(Text("learn ").foregroundColor(.orange).underline(true, color: .orange))\
        \(Text("how \nto ").foregroundColor(.black))\
        \(Text("bake ").foregroundColor(.purple).underline(true, color: .purple))\
        \(Text("this \nweekend.").foregroundColor(.black))
        """)
        .font(.system(size: 44, weight: .bold, design: .default))
        .lineSpacing(4)
        .multilineTextAlignment(.leading)
    }
}

#Preview {
    OnboardingView()
}
