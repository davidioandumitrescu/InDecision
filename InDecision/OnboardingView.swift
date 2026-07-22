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
    
    // Cycles every 4 seconds.
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    // MARK: - Theme Colors
//<<<<<<< HEAD
//    private let bgTeal = Color.mint
//    private let accentGreen = Color(red: 0.20, green: 0.80, blue: 0.35)
//    private let btnPurple = Color(red: 0.50, green: 0.35, blue: 0.96)
//=======
    private let bgTeal = Color("AppSurface")
    // private let bgTeal = Color("red: 0.05, green: 0.78, blue: 0.67")
    private let accentGreen = Color("ColorGreen")
    private let btnPurple = Color("AppPrimary")
//>>>>>>> itroy
    private let darkCyan = Color(red: 0.0, green: 0.5, blue: 0.5)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Background Layers
                bgTeal.ignoresSafeArea()
                
                // Bottom Right Staggered Shape
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 0) {
                            accentGreen.frame(width: 130, height: 70)
                            accentGreen.frame(width: 250, height: 70)
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                // 2. Main Content Layer
                VStack(spacing: 0) {
                    
                    // MARK: - HEADER
                    HStack {
                        HStack(spacing: 8) {
                            Image("BloopLogo-Sml")
                        
                        }
                        .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
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
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.easeInOut(duration: 0.8), value: currentIndex)
                    
                    Spacer()
                    
                    // MARK: - SUBTEXT
                    VStack(spacing: 6) {
                        Text("Connect with ") + Text("local").underline() + Text(" people")
                        Text("doing fun things.")
                    }
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
                    
                    // MARK: - ACTION BUTTONS
                    VStack(spacing: 16) {
                        
                        // 1. Find things to do
                        Button(action: {
                            eventManager.selectedTab = 0
                            hasSeenOnboarding = true
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Find things to do")
                            }
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(btnPurple)
                            .clipShape(Capsule())
                        }
                        
                        // 2. Start something new
                        Button(action: {
                            eventManager.selectedTab = 1
                            hasSeenOnboarding = true
                        }) {
                            HStack {
                                Image(systemName: "text.badge.plus")
                                Text("Start something new")
                            }
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.black)
                            .clipShape(Capsule())
                        }
                        
                        // 3. I'm not sure
                        NavigationLink(destination: InfoView()) {
                            HStack(spacing: 6) {
                                Image(systemName: "questionmark.circle")
                                Text("I'm not sure")
                            }
                            .font(.headline)
                            .foregroundColor(btnPurple)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                }
            }
            .onReceive(timer) { _ in
                currentIndex = (currentIndex + 1) % 3
            }
        }
    }
    
    // MARK: - TEXT VARIATIONS (Using AttributedString for highlighted backgrounds)
    
    // Helper function to easily generate highlighted text blocks
    private func textBlock(_ string: String, color: Color, bg: Color? = nil) -> AttributedString {
        var attr = AttributedString(string)
        attr.foregroundColor = color
        if let bg = bg {
            attr.backgroundColor = bg
        }
        return attr
    }
    
    // Variation 1 (Matches the visual mockup)
    var phraseOne: some View {
        var str = AttributedString()
        str.append(textBlock("Dan", color: Color("ColorOrange"), bg: Color("ColorYellow")))
        str.append(textBlock(" wants\n", color: Color("ColorBlack")))
        str.append(textBlock("2-6 ", color: Color("AppSurface"), bg: Color("ColorBlack")))
        str.append(textBlock(" ", color:Color("AppSurface")))
        str.append(textBlock("people", color: .white, bg: accentGreen))
        str.append(textBlock(" ", color:Color("AppSurface")))
        str.append(textBlock("to do ", color: .white))
        str.append(textBlock("tai-chi", color: .yellow, bg: btnPurple))
        str.append(textBlock(" ", color:Color("AppSurface")))
        str.append(textBlock("with", color: .white))
        
        str.append(textBlock("tomorrow.", color: btnPurple))
        
        return Text(str)
            .font(.system(size: 48, weight: .bold, design: .default))
            .lineSpacing(6)
            .multilineTextAlignment(.leading)
    }
    
    // Variation 2
    var phraseTwo: some View {
        var str = AttributedString()
        str.append(textBlock("I want\n", color: .black))
        str.append(textBlock("people ", color: .white, bg: .blue))
        str.append(textBlock("to\nshare ", color: .black))
        str.append(textBlock("this ", color: .yellow, bg: btnPurple))
        str.append(textBlock("with.", color: .white))
        
        return Text(str)
            .font(.system(size: 48, weight: .bold, design: .default))
            .lineSpacing(6)
            .multilineTextAlignment(.leading)
    }
    
    // Variation 3
    var phraseThree: some View {
        var str = AttributedString()
        str.append(textBlock("I'd love\nto ", color: .black))
        str.append(textBlock("learn ", color: .black, bg: .orange))
        str.append(textBlock("how\nto ", color: .black))
        str.append(textBlock("bake ", color: .white, bg: .pink))
        str.append(textBlock("\nthis weekend.", color: .white))
        
        return Text(str)
            .font(.system(size: 48, weight: .bold, design: .default))
            .lineSpacing(6)
            .multilineTextAlignment(.leading)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(EventManager())
}
