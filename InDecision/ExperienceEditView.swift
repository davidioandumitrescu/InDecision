//
//  ExperienceEditView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 21/7/2026.
//
import SwiftUI

struct ExperienceEditView: View {
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.dismiss) var dismiss
    
    let event: DetailedEvent
    
    @State private var activity: String
    @State private var connectionTarget: String
    @State private var minPeople: Double
    @State private var maxPeople: Double
    @State private var location: String
    @State private var experienceType: String
    @State private var time: Date
    @State private var isSaving = false
    
    private let experienceTypes = [
        "Teach", "Demonstrate", "StoryTell", "Build", "Mentor", "Explore", "Discuss", "Practice"
    ]
    
    init(event: DetailedEvent) {
        self.event = event
        _activity = State(initialValue: event.activity)
        _connectionTarget = State(initialValue: event.connectionTarget)
        _minPeople = State(initialValue: event.minPeople)
        _maxPeople = State(initialValue: event.maxPeople)
        _location = State(initialValue: event.location)
        _experienceType = State(initialValue: event.experienceType)
        _time = State(initialValue: event.time)
    }
    
    private let bgOrange = Color("ColorOrange")
    private let accentCyan = Color("AppPrimary")

    var body: some View {
        NavigationStack {
            ZStack {
                bgOrange.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Activity Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Activity").font(.subheadline.bold()).foregroundColor(.white)
                            TextField("Activity", text: $activity)
                                .padding()
                                .background(Color.black.opacity(0.2))
                                .clipShape(Capsule())
                                .foregroundColor(.white)
                        }
                        
                        // Connection Target Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Looking to connect with").font(.subheadline.bold()).foregroundColor(.white)
                            TextField("Audience", text: $connectionTarget)
                                .padding()
                                .background(Color.black.opacity(0.2))
                                .clipShape(Capsule())
                                .foregroundColor(.white)
                        }
                        
                        // Experience Type Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Experience Type").font(.subheadline.bold()).foregroundColor(.white)
                            Picker("Type", selection: $experienceType) {
                                ForEach(experienceTypes, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                        }
                        
                        // Capacity Section (Slider)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("With how many people?")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            
                            if maxPeople < 2 {
                                Text("one person")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            } else if minPeople == 0 {
                                Text("up to \(Int(maxPeople)) people")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            } else if Int(minPeople) == Int(maxPeople) {
                                Text("\(Int(maxPeople)) people")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(Int(minPeople)) to \(Int(maxPeople)) people")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 14) {
                                Image(systemName: "person.fill").foregroundColor(.white.opacity(0.7))
                                
                                RangeSlider(
                                    lowerValue: $minPeople,
                                    upperValue: $maxPeople,
                                    bounds: 1...20
                                )
                                .padding(.vertical)
                                
                                Image(systemName: "person.3.fill").foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 16)
                            .background(Color.black.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        
                        // Time Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("At this time").font(.subheadline.bold()).foregroundColor(.white)
                            
                            HStack {
                                Text(formattedTime)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                DatePicker(
                                    "",
                                    selection: $time,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .colorInvert()
                                .colorMultiply(.white)
                            }
                            .padding(16)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Capsule())
                        }
                        
                        // Location Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location").font(.subheadline.bold()).foregroundColor(.white)
                            TextField("Location", text: $location)
                                .padding()
                                .background(Color.black.opacity(0.2))
                                .clipShape(Capsule())
                                .foregroundColor(.white)
                        }
                        
                        Spacer(minLength: 30)
                        
                        // Save Button
                        Button(action: {
                            Task {
                                isSaving = true
                                var updatedEvent = event
                                updatedEvent.activity = activity
                                updatedEvent.connectionTarget = connectionTarget
                                updatedEvent.minPeople = minPeople
                                updatedEvent.maxPeople = maxPeople
                                updatedEvent.location = location
                                updatedEvent.experienceType = experienceType
                                updatedEvent.time = time
                                
                                let success = await eventManager.updateEvent(updatedEvent)
                                isSaving = false
                                if success {
                                    dismiss()
                                }
                            }
                        }) {
                            HStack {
                                if isSaving {
                                    ProgressView().tint(.black)
                                } else {
                                    Text("Save Changes").bold()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                        }
                        .disabled(isSaving)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
}
