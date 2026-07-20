//
//  ExperienceDetailView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI

struct ExperienceDetailView: View {
    let event: DetailedEvent
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.dismiss) var dismiss
    
    //UI background layer
    private let themeGreen = Color(red: 0.0, green: 0.8, blue: 0.65)
    private let buttonPurple = Color(red: 0.45, green: 0.35, blue: 0.95)
    
    var body: some View {
        
        ZStack{
            themeGreen
                .ignoresSafeArea()
            
            //1. right bottom green geometric boxes
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                            Color.green.opacity(0.3).frame(width: 150, height: 100)
                            Color.green.opacity(0.4).frame(width: 250, height: 100)
                    }
                }
            }
            .ignoresSafeArea()
            
            //2. core content layer
            VStack(alignment: .leading, spacing: 24) {
                headerBar // defined later
                let numMore = event.maxPeople - event.joinedCount
                
                ScrollView(.vertical, showsIndicators: false){
                    VStack(alignment: .leading, spacing: 22){
                       
                        Text("\(numMore) more people to reach goal!")  // need to obtain data from the database
                            .font(.system(size: 18, weight: .bold))
                            .fontWeight(.medium)
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.top, 10)
                        
                        Text("\(event.hostName) wants \(Int(event.maxPeople)) adventurers to go \(event.activity)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .lineSpacing(6)
                        
                        tagsSection
                        
                        infoRowsSection
                        
                        socialStatsBar
                        
                        attendeesAvatersSection
                        
                        Spacer(minLength: 40)
                        
                        actionButtonsArea
                    }
                }
                
                
                
            }
            .padding(.horizontal, 24)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: - subsections:
    //a. headerbar
    private var headerBar: some View {
        HStack{
            HStack(spacing:8){
                Image(systemName:"person.3.fill")
                    .font(.system(size:35))
                    .foregroundColor(.white)
                Text("Bloop")
                    .font(.system(size:30, weight:.bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: {dismiss()}) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size:50))
                    .foregroundColor(.white)
            }
                
        }
        .padding(.top,10)
    }
    
    //b.tagsSection
    private var tagsSection: some View {
        HStack (spacing:10){
            Text(event.experienceType)
                .font(.system(size:20, weight:.bold))
                .fontWeight(.semibold)
                .padding(.horizontal, 14)
                .padding(.vertical,8)
                .background(Color.black.opacity(0.15))
                .foregroundColor(.white)
                .clipShape(Capsule())
            
            Text("Adventure") // later link to tags attribute of event
                .font(.system(size:20, weight:.bold))
                .fontWeight(.semibold)
                .padding(.horizontal, 14)
                .padding(.vertical,8)
                .background(Color.black.opacity(0.15))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .padding()
    }
    
    //c. location & time row
    private var infoRowsSection: some View {
        VStack(alignment:.leading, spacing:14) {
            HStack(spacing:10){
                Image(systemName: "location.north.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                Text(event.location)
                    .font(.system(size: 18))
                    .foregroundColor(.black.opacity(0.7))
            }
            HStack(spacing:10){
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                Text("\(event.time)") // no date for event.
                    .font(.system(size: 18))
                    .foregroundColor(.black.opacity(0.7))
            }
        }
        .fontWeight(.medium)
    }
        
    //d. likes counts and data
    private var socialStatsBar: some View {
        HStack(spacing:16){
            HStack(spacing:6){
                Image(systemName: "heart.circle")
                    .foregroundColor(.pink.opacity(0.7))
                    .font(.system(size: 24, weight: .bold))
                Text("\(event.likeCount)") //later to pass the event saved data
                    .foregroundColor(.black.opacity(0.7))
            }
            HStack(spacing:6){
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black.opacity(0.7))
                Text("\(event.joinedCount)") //later to pass the event saved data
                    .foregroundColor(.black.opacity(0.7))
            }
        }
        .font(.subheadline)
        .fontWeight(.bold)
    }
    
    //e. user avatar banner. dummy data to be replaced by superbase. there are conflicts. so i use dummies now.
    private var dummyUsers: [Profile] {
            [
                Profile(id: UUID(uuidString: "abc123e4-be33-40ef-a417-e5166e307b5e")!, username: "j", full_name: "Jacob Gellard", avatar_url: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200"),
                Profile(id: UUID(uuidString: "cd5b0a98-957e-42f0-8311-8224df346b59")!, username: "davidioan", full_name: "David Dumitrescu", avatar_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200"),
                Profile(id: UUID(), username: "lisa", full_name: "Lisa Li", avatar_url: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200"),
            ]
        }
    
    private var attendeesAvatersSection: some View {
        HStack(spacing:10){
            ForEach(dummyUsers){user in
                let isHost = user.id == event.created_by
                
                ZStack(alignment:.trailing){
                    //1) image
                    if let avatarStr = user.avatar_url, let url = URL(string: avatarStr){
                        AsyncImage(url: url){image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName:  "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(Color.gray.opacity(0.4))
                        }
                        .frame(width: 54, height: 54)
                        .clipShape(Circle())
                        // 2) host: purple outline
                        .overlay(
                            Circle()
                                .stroke(isHost ? Color(red: 0.45, green:0.35, blue:0.95) : .gray.opacity(0.6), lineWidth: 3)
                        )
                    }
                    if isHost{
                        Image(systemName:"checkmark.seal.fill")
                            .resizable( )
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                            .background(Circle().fill(.white).frame(width: 18, height: 18))
                            .offset(x: 4, y:-20)
                        
                    }
                }
            }
        }
    }
    

    private func avatarImage(sysName:String, strokeColor:Color)-> some View {
        Image(systemName: sysName)
            .resizable()
            .scaledToFill()
            .frame(width: 54, height: 54)
            .background(.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 3)).foregroundColor(strokeColor))
        
    }
    
    // f. add the buttons to join and save
    private var actionButtonsArea: some View{
        VStack(spacing:12){
            Button(action:{print("Join Event: \(event.id)")
            }){
                //                HStack{
                //                    Image(systemName:"checkmark.circle")
                //                    Text("Yes, I'm in!")
                //                        .fontWeight(.bold)
                //                }
                Label("Yes, I'm in!", systemImage: "checkmark.circle")
                    .font(Font.body.bold())
                    .background(buttonPurple.frame(width: 200, height: 54).cornerRadius(10))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height:54)
                    .clipShape(Capsule())
                    .shadow(color:buttonPurple.opacity(0.9), radius: 8, x:0, y:4)
            }
            Button(action:{
                eventManager.toggleSave(for: event.id)
            }){
                Label("Save for later", systemImage: "heart.fill")
                    .font(Font.body.bold())
                    .foregroundColor(buttonPurple)
                    .frame(maxWidth: .infinity)
                    .frame(height:54)
                    .clipShape(Capsule())
                    .shadow(color:buttonPurple.opacity(0.9), radius: 8, x:0, y:4)
            }
            .padding(.bottom, 50)
        }
    }
}
    
    

#Preview {
    let previewTime = Date()
    
    ExperienceDetailView(
        event: DetailedEvent(
            id: UUID(uuidString: "54514bd0-c8b5-4268-8038-db8e07a2efce")!,
            hostName: "Dan",
            location: "Nollamara, Perth Western Australia",
            experienceType: "Sport",
            created_by: UUID(uuidString: "abc123e4-be33-40ef-a417-e5166e307b5e"),
            activity: "rock climbing",
            connectionTarget: "adventurers",
            minPeople: 5,
            maxPeople: 8,
            selectedDays: ["Mondays", "Tuesdays"],
            time: previewTime,                     
            imgUrl: "",
            isSolid: false,
            likeCount: 34,
            joinedCount: 3
        )
    )
    .environmentObject(EventManager())
}
