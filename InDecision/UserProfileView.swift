//
//  UserProfileView.swift
//  InDecision
//
//  Created by Tracy on 17/7/2026.
//

import SwiftUI

struct UserProfileView: View {
     @EnvironmentObject var eventManager: EventManager
    @State private var currentUser = User(name: "tracy", email: "abc", phonenumber: "edf", gender: "female")
    

    
    var body: some View {
        NavigationStack {
            Text("Hello, \(currentUser.name)")
                .font(.largeTitle)
                .padding()
            ZStack{
                // whole page gray background
                Color(UIColor.systemGray6)
                    .ignoresSafeArea(edges: .all)
                
                ScrollView(.vertical, showsIndicators: false){
                    
                    //overall outline formatting
                    VStack(alignment:.leading, spacing: 24){
                        //1. top personal and info
                        VStack(spacing:16){
                            
                            //profile photo
                            ZStack{
                                Circle()
                                    .fill(Color.purple.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.purple)
                                  
                            }
                            .padding(.top, 20)
                            
                            //jump to details
                            NavigationLink(destination: Text("Personal Information Detail View")){
                                HStack{
                                    Text("Personal Details")
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(20)
                            }
                            
                        }
                        // II. interest, created, joined
                        VStack(alignment:.leading, spacing:12){

                            //2. interest modules

                            
                            // interest tags need to use looping with a container
                            VStack(alignment: .leading, spacing:10){
                                Text("Interests")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                HStack(spacing:10){
                                    InterestTag(title: "Music")
                                    InterestTag(title: "Movies")
                                    InterestTag(title: "Sports")
                                    }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(20)
                                }
                            .padding()
                            
                            // 3. events created
                            VStack(alignment:.leading, spacing:12){
                                Text("Created")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                //changed to this one later
//                                EventRowView(event: dummyCreatedEvent)
//                                            .background(Color.white)
//                                            .cornerRadius(20)
                                
                                    
                                HStack(spacing:10){
                                    // jump to event details
                                    NavigationLink(destination:ExperienceCreateView()){
                                        // event title
                                        Text("Learn Baking!")
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                            .onTapGesture{}
                                        
                                            .padding()
                                        
                                        Spacer()
                                        
                                        // event time location
                                        VStack{
                                            Text("Time: 10:00 AM - 12:00 PM")
                                                .foregroundColor(.black)
                                            Text("Location: 123 Main St, Anytown")
                                                .foregroundColor(.black)
                                        }
                                        
                                        
                                        
                                        // nagivation link
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.blue)

                                     }
                                }
                                
                                .padding()
                                .background(Color.white)
                                .cornerRadius(20)
                            }
                            .padding()
                            
                            //4. participating history
                            VStack(alignment:.leading, spacing:12){
                                Text("Joined")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                
                                HStack{
                                    
                                    HStack(spacing:10){
                                        //ExperienceDetailView(event: Event())
                                        NavigationLink(destination:Text("need actual event details")){
                                                // event title
                                                Text("Spice Sharing")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.black)
                                                    .onTapGesture{}
                                                
                                                    .padding()
                                                
                                                Spacer()
                                                
                                                // event time location
                                                VStack{
                                                    Text("Time: 10:00 AM - 12:00 PM")
                                                        .foregroundColor(.black)
                                                    Text("Location: 123 Main St, Anytown")
                                                        .foregroundColor(.black)
                                                }
                                                
                                                
                                                
                                                // nagivation link
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.blue)

                                             }
                                    }
                                }
                                
                                .padding()
                                .background(Color.white)
                                .cornerRadius(20)
                            }
                            .padding()
                                
                            
                            
                            }
                     
                        }
                    }
                        
                        
                }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
//                    Button(action:{
//                        .none
//                    }){
//                        Image(systemName:"arrowshape.backward.circle.fill")
//                    }
                    //ExperienceDetailView(event: <#DetailedEvent#>)
                    NavigationLink(destination: Text("need actual events joined")) {
                        Image(systemName:"arrowshape.backward.circle.fill")
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                             .clipShape(Circle())
                    }
                    
                }
            }
                    
            }
                
        }
            
    }


struct InterestTag: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(20)
    }
}

struct EventRowView: View{
    let event: DetailedEvent
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 6){
                Text(event.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Time: \(event.time)")
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                Text("Location: \(event.location)")
                    .font(.subheadline)
                    .foregroundColor(.black)
                
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.blue)
        }
        .padding()
    }
}



#Preview {
    UserProfileView()
}
