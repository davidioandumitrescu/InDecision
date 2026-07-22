//
//  ExperienceView.swift
//  InDecision
//
//  Created by David-Ioan Dumitrescu on 16/7/2026.
//

import SwiftUI
import UIKit   // for haptic feedback

// MARK: - 1. THE REVERSED STAGGERED SHAPE
struct StaggeredBottomShape: Shape {
    var steps: Int = 3
    var stepHeight: CGFloat = 30
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stepWidth = rect.width / CGFloat(steps)
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        
        let highestPointOnRight = rect.height - (CGFloat(steps - 1) * stepHeight)
        path.addLine(to: CGPoint(x: rect.width, y: highestPointOnRight))
        
        for i in (0..<steps).reversed() {
            let currentX = CGFloat(i) * stepWidth
            let currentY = rect.height - (CGFloat(i) * stepHeight)
            path.addLine(to: CGPoint(x: currentX, y: currentY))
            if i != 0 {
                let nextStepDownY = rect.height - (CGFloat(i - 1) * stepHeight)
                path.addLine(to: CGPoint(x: currentX, y: nextStepDownY))
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - 2. CARD VIEW
struct StaggeredEventCard: View {
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var authManager: AuthManager

    var event: DetailedEvent
    var bgColor: Color
    var nextColor: Color
    
    var stepHeight: CGFloat = 30
    var steps: Int = 3
    var isFirstItem: Bool = false
    
    @State private var likeAnimationActive = false
    
    var body: some View {
        let overlapAmount = stepHeight * CGFloat(steps - 1)
        let remainingPeople = max(0, Int(event.maxPeople) - event.joinedCount)
        let shape = StaggeredBottomShape(steps: steps, stepHeight: stepHeight)
        
        VStack(alignment: .leading, spacing: 16) {
            if (remainingPeople > 0){
                Text("\(remainingPeople) more people to reach goal!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))}
            else{
                Text("Event filled!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
            }
            
            NavigationLink(destination: ExperienceDetailView(event: event, bgColor: bgColor, nextColor: nextColor)) {
                Text(event.generatedTitle)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .onTapGesture(count: 2) {
                        Task { await eventManager.toggleSave(for: event.id, userID: authManager.userID) }
                        withAnimation { likeAnimationActive = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            likeAnimationActive = false
                        }
                    }
            }
            .buttonStyle(PlainButtonStyle())
            
            HStack(spacing: 12) {
                Text(event.isSolid ? "Solid" : "Proposed")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(event.isSolid ? Color.white.opacity(0.4) : Color.black.opacity(0.3))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
                
                Text(event.experienceType)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill").foregroundColor(.red)
                    Text("\(event.likeCount)").foregroundColor(.black.opacity(0.6))
                }.font(.subheadline.bold())
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.black.opacity(0.6))
                    Text("\(event.joinedCount)").foregroundColor(.black.opacity(0.6))
                }.font(.subheadline.bold())
            }
        }
        .padding(.top, isFirstItem ? 200 : 48 + overlapAmount)
        .padding(.horizontal, 32)
        .padding(.bottom, 60 + overlapAmount)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bgColor)
        .overlay(
            Group {
                if likeAnimationActive {
                    Rectangle()
                        .fill(Color.white.opacity(0.25))
                        .blur(radius: 8)
                        .scaleEffect(1.02)
                        .transition(.opacity)
                        .animation(.easeOut(duration: 0.3), value: likeAnimationActive)
                    
                    ShineView(shape: shape)
                }
            }
        )
        .clipShape(shape)
        // 👇 HAPTIC SUPPORT: report the card's vertical center in global coordinates
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: CardMidYKey.self,
                        value: [event.id.uuidString: geo.frame(in: .global).midY]   // ✅ use uuidString
                    )
            }
        )
    }
}

// MARK: - SHINE VIEW
struct ShineView: View {
    let shape: StaggeredBottomShape
    
    @State private var offsetX: CGFloat = -1.0
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.6), location: 0.3),
                            .init(color: .white.opacity(0.9), location: 0.5),
                            .init(color: .white.opacity(0.6), location: 0.7),
                            .init(color: .clear, location: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .mask(shape)
                .offset(x: offsetX * geometry.size.width * 1.2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        offsetX = 1.0
                    }
                }
        }
    }
}

// MARK: - FILTER LAYOUT
private struct FilterBubbleLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let rows = makeRows(maxWidth: proposal.width ?? .infinity, subviews: subviews)
        let contentWidth = rows.map(\.width).max() ?? 0
        let contentHeight = rows.reduce(0) { $0 + $1.height }
            + verticalSpacing * CGFloat(max(rows.count - 1, 0))

        return CGSize(width: proposal.width ?? contentWidth, height: contentHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = makeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX

            for item in row.items {
                item.subview.place(
                    at: CGPoint(x: x, y: y + (row.height - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + horizontalSpacing
            }

            y += row.height + verticalSpacing
        }
    }

    private func makeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let requiredWidth = currentRow.items.isEmpty
                ? size.width
                : currentRow.width + horizontalSpacing + size.width

            if !currentRow.items.isEmpty, requiredWidth > maxWidth {
                rows.append(currentRow)
                currentRow = Row()
            }

            currentRow.items.append(Item(subview: subview, size: size))
            currentRow.width += (currentRow.items.count == 1 ? 0 : horizontalSpacing) + size.width
            currentRow.height = max(currentRow.height, size.height)
        }

        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }

    private struct Item {
        let subview: LayoutSubview
        let size: CGSize
    }

    private struct Row {
        var items: [Item] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }
}

// MARK: - PREFERENCE KEYS
struct CardMidYKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue()) { $1 }
    }
}

struct HeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - 3. MAIN LIST
struct ExperienceListView: View {
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var searchText = ""
    @State private var selectedFilter = 0
    @State private var selectedTypes: Set<String> = []
    
    let experienceTypes = ["All", "Teach", "Demonstrate", "StoryTell", "Build", "Mentor", "Explore", "Discuss", "Practice"]
    
    let palette: [Color] = [.mint, .green, .yellow, .orange]
    let stepCount = 3
    let stepHeight: CGFloat = 30

    // MARK: - Haptic tracking
    @State private var headerHeight: CGFloat = 0
    @State private var triggeredCardIDs = Set<String>()
    private let hapticTolerance: CGFloat = 20
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    var filterEvents: [DetailedEvent] {
        eventManager.events.filter { event in
            let matchesSearch = searchText.isEmpty || event.generatedTitle.localizedCaseInsensitiveContains(searchText) || event.hostName.localizedCaseInsensitiveContains(searchText)
            
            let matchesSegment: Bool
            if selectedFilter == 1 { matchesSegment = !event.isSolid }
            else if selectedFilter == 2 { matchesSegment = event.isSolid }
            else { matchesSegment = true }
            
            let matchesType = selectedTypes.isEmpty || selectedTypes.contains(event.experienceType)
            
            return matchesSearch && matchesSegment && matchesType
        }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    
                    // MARK: - SCROLLING LIST
                    ScrollView(.vertical, showsIndicators: false) {
                        let overlapAmount = stepHeight * CGFloat(stepCount - 1)
                        
                        if filterEvents.isEmpty {
                            VStack(spacing: 16) {
                                Text("No events match your search.")
                                    .foregroundColor(.gray)
                                if eventManager.events.isEmpty && eventManager.errorMessage.isEmpty {
                                    ProgressView()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 200)
                        } else {
                            VStack(spacing: -overlapAmount) {
                                ForEach(Array(filterEvents.enumerated()), id: \.element.id) { index, event in
                                    StaggeredEventCard(
                                        event: event,
                                        bgColor: palette[index % palette.count],
                                        nextColor: palette[(index + 1) % palette.count],
                                        stepHeight: stepHeight,
                                        steps: stepCount,
                                        isFirstItem: index == 0
                                    )
                                    .zIndex(Double(filterEvents.count - index))
                                }
                            }
                            .padding(.bottom, overlapAmount)
                            
                            Button(action: {
                                eventManager.selectedTab = 1
                            }) {
                                Text("Can't find anything interesting?\n**Suggest something.**")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.96))
                            }
                            .padding(.bottom, 60)
                        }
                    }
                    .background(palette.first?.ignoresSafeArea())
                    .ignoresSafeArea(edges: .top)
                    
                    // MARK: - PINNED HEADER
                    VStack(spacing: 16) {
                        
                        // Search Bar & Profile Button
                        HStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass").foregroundColor(.gray).font(.system(size: 20))
                                TextField("Explore", text: $searchText).font(.system(size: 18))
                                Image(systemName: "mic").foregroundColor(.gray).font(.system(size: 20))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            Menu {
                                ForEach(experienceTypes, id: \.self) { type in
                                    Toggle(
                                        type,
                                        isOn: Binding(
                                            get: {
                                                type == "All"
                                                    ? selectedTypes.isEmpty
                                                    : selectedTypes.contains(type)
                                            },
                                            set: { isSelected in
                                                if type == "All" {
                                                    if isSelected {
                                                        selectedTypes.removeAll()
                                                    }
                                                } else if isSelected {
                                                    selectedTypes.insert(type)
                                                } else {
                                                    selectedTypes.remove(type)
                                                }
                                            }
                                        )
                                    )
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.black)
                                    .frame(width: 50, height: 50)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            NavigationLink(destination: ProfileDestinationView()) {
                                AvatarView(userID: authManager.userID)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Segmented Control
                        Picker("Filter", selection: $selectedFilter) {
                            Text("All").tag(0)
                            Text("Proposed").tag(1)
                            Text("Solid").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        // Active Filter Indicator
                        if !selectedTypes.isEmpty {
                            FilterBubbleLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                                ForEach(experienceTypes.filter { selectedTypes.contains($0) }, id: \.self) { type in
                                    Button {
                                        selectedTypes.remove(type)
                                    } label: {
                                        HStack(spacing: 6) {
                                            Text(type)
                                            Image(systemName: "xmark")
                                        }
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.black.opacity(0.7))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Color.white.opacity(0.85))
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Remove \(type) filter")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity)
                    .background {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .mask {
                                LinearGradient(
                                    stops: [
                                        .init(color: .black, location: 0.0),
                                        .init(color: .black, location: 0.65),
                                        .init(color: .black.opacity(0.7), location: 0.82),
                                        .init(color: .black.opacity(0.25), location: 0.94),
                                        .init(color: .clear, location: 1.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                            .ignoresSafeArea(edges: .top)
                    }
                    // 👇 Measure header height for haptic zone calculation
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: HeaderHeightKey.self, value: geo.size.height)
                        }
                    )
                    .zIndex(1)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.ignoresSafeArea())
                .toolbar(.hidden, for: .navigationBar)
                // 👇 Listen to card positions and trigger haptics
                .onPreferenceChange(CardMidYKey.self) { cardPositions in
                    handleCardPositions(cardPositions, in: geo)
                }
                .onPreferenceChange(HeaderHeightKey.self) { height in
                    headerHeight = height
                }
            }
        }
        .task {
            await eventManager.loadEvents()
            await eventManager.loadSavedEvents(for: authManager.userID)
            await eventManager.loadJoinedEvents(for: authManager.userID)
        }
    }
    
    // MARK: - Haptic Handling
    private func handleCardPositions(_ positions: [String: CGFloat], in geo: GeometryProxy) {
        // Visible center Y (below the header)
        let visibleCenterY = (headerHeight + geo.size.height) / 2 + 35
        
        var newlyTriggeredIDs = Set<String>()
        var idsInZone = Set<String>()
        
        for (id, midY) in positions {
            let distance = abs(midY - visibleCenterY)
            if distance < hapticTolerance {
                idsInZone.insert(id)
                if !triggeredCardIDs.contains(id) {
                    newlyTriggeredIDs.insert(id)
                }
            }
        }
        
        // Trigger haptic for newly entered cards
        for id in newlyTriggeredIDs {
            hapticGenerator.impactOccurred()
        }
        
        // Update the set of triggered cards
        triggeredCardIDs = idsInZone
    }
}

#Preview {
    ExperienceListView()
        .environmentObject(EventManager())
        .environmentObject(AuthManager())
}
