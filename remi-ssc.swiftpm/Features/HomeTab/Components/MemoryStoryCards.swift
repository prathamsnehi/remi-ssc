import SwiftUI
import SwiftData

struct MemoryStoryCardsView: View {
    @Query(sort: \Person.lastInteracted, order: .reverse) var savedPersons: [Person]
    let height: CGFloat
    var onScanFace: (() -> Void)? = nil
    let maxCardsDisplayed = 5
    
    // Maintain a standard aspect ratio (approx 0.64 which is 320/500)
    private var cardWidth: CGFloat {
        height * 0.64
    }
    
    @State private var activeID: UUID?
    @State private var storyIndices: [UUID: Int] = [:]
    
    private func binding(for id: UUID) -> Binding<Int> {
        Binding(
            get: { storyIndices[id, default: 0] },
            set: { storyIndices[id] = $0 }
        )
    }
    
    private var personsToShow: [Person] {
        Array(savedPersons.prefix(maxCardsDisplayed))
    }
    
    @State private var specialPadding: (Double, Double) = (0, 0)
    
    func updateCardPadding(index: Int, normalPaddingAmount: Double, specialPaddingAmount: Double) {
        if personsToShow.count == 1 {
            self.specialPadding = (normalPaddingAmount, normalPaddingAmount)
        } else if index == 0 {
            self.specialPadding = (specialPaddingAmount, normalPaddingAmount)
        } else if index == personsToShow.count - 1  {
            self.specialPadding = (normalPaddingAmount, specialPaddingAmount)
        } else {
            self.specialPadding = (normalPaddingAmount, normalPaddingAmount)
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { proxy in
                let cardWidth = proxy.size.width * 0.85
                
                if personsToShow.isEmpty {
                    PlaceholderMemoryCard(width: cardWidth, height: height, action: onScanFace)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    let normalPadding = (proxy.size.width - cardWidth) / 2
                    let specialPaddingAmount = 20.0
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(personsToShow) { person in
                                MemoryStoryCard(
                                    person: person,
                                    width: cardWidth,
                                    height: height,
                                    currentSlideIndex: binding(for: person.id)
                                )
                                .id(person.id)
                            }
                        }
                        .padding(.leading, specialPadding.0)
                        .padding(.trailing, specialPadding.1)
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $activeID)
                    .onAppear {
                        if activeID == nil {
                            activeID = personsToShow.first?.id
                            updateCardPadding(index: 0, normalPaddingAmount: normalPadding, specialPaddingAmount: specialPaddingAmount)
                        }
                    }
                    .onChange(of: activeID) { oldValue, newValue in
                        if let id = newValue, let index = personsToShow.firstIndex(where: { $0.id == id }) {
                            // Update padding immediately without animation to avoid scroll lag
                            updateCardPadding(index: index, normalPaddingAmount: normalPadding, specialPaddingAmount: specialPaddingAmount)
                        }
                    }
                }
            }
            .frame(height: height)
            
            // Pagination Dots only if there are people
            if !personsToShow.isEmpty {
                HStack(spacing: 8) {
                    ForEach(personsToShow) { person in
                        Circle()
                            .fill(activeID == person.id ? Color.primary : Color.secondary.opacity(0.3))
                            .frame(width: 6, height: 6)
                            .scaleEffect(activeID == person.id ? 1.2 : 1.0)
                            .animation(.spring(), value: activeID)
                    }
                }
                .padding(.bottom, 10)
            }
        }
    }
}

struct PlaceholderMemoryCard: View {
    let width: CGFloat
    let height: CGFloat
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color("AppSurface")) // Subtle card background
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                    )
                
                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color("AppPrimary").opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "face.dashed") // Scan face icon
                            .font(.system(size: 40))
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    
                    // Text
                    VStack(spacing: 8) {
                        Text("Add a Loved One")
                            .font(.system(.title2, design: .rounded, weight: .bold)) // Clean
                            .foregroundStyle(Color("AppPrimaryText"))
                        
                        Text("Scan their face to start remembering.")
                            .font(.system(.body, design: .rounded)) // Minimalistic
                            .foregroundStyle(Color("AppSecondaryText"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .frame(width: width, height: height)
        }
        .buttonStyle(.plain) // No press effect needed for card
    }
}

struct MemoryStoryCard: View {
    let person: Person
    let width: CGFloat
    let height: CGFloat
    
    @Binding var currentSlideIndex: Int
    @State private var timer: Timer?
    
    // Filter memories that have photos
    private var photoMemories: [Memory] {
        person.memories.filter { $0.photoData != nil }
    }
    
    // Combine person's photo with memory photos
    private var slides: [Data] {
        var allSlides = [person.photoData]
        allSlides.append(contentsOf: photoMemories.compactMap { $0.photoData })
        return allSlides
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Image & Gradient (Passive Content)
            if let imageData = slides[safe: currentSlideIndex], let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: width, height: height)
            }
            
            // Gradient Overlay for readability
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.65),
                    .init(color: .black.opacity(0.8), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
            
            // Navigation Link (Invisible Overlay - Captures tap on body)
            NavigationLink(destination: FriendProfileView(person: person)) {
                Color.clear
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain) // Critical for avoiding list cell styling interference in ScrollView
            
            // Story Progress Pills (Top)
            VStack(spacing: 0) {
                if slides.count > 1 {
                    HStack(spacing: 4) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Capsule()
                                .fill(index <= currentSlideIndex ? Color.white : Color.white.opacity(0.3))
                                .frame(height: 3)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 12)
                }
                Spacer()
            }
            .allowsHitTesting(false) // Let touches pass through the empty space
            

            // Bottom Content Overlay (Name & Relation) - Purely Visual Overlay
            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.system(.title, design: .rounded, weight: .bold)) // Requested size
                    .foregroundStyle(.white) // Requested color
                
                Text(person.relation)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9)) // Requested opacity
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.white.opacity(0.2))) // Subtle pill background for relation
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .allowsHitTesting(false) // Let taps pass through to NavigationLink below
            
            // Tap areas for navigation arrows (Invisible controls for story slides)
            // Left/Right edges navigate stories, Center falls through to Profile Navigation
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: width * 0.25) // Reduced tap width
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigate(direction: -1)
                    }
                
                Spacer() // Middle 50% allows taps to fall through to the NavigationLink behind
                
                Color.clear
                    .frame(width: width * 0.25) // Reduced tap width
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigate(direction: 1)
                    }
            }
        }
        .frame(width: width, height: height)
        .background(Color.black.opacity(0.1)) // Base background
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
        )
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func navigate(direction: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            let nextIndex = currentSlideIndex + direction
            if nextIndex >= 0 && nextIndex < slides.count {
                currentSlideIndex = nextIndex
            } else if nextIndex >= slides.count {
                currentSlideIndex = 0
            }
        }
        restartTimer()
    }
    
    private func startTimer() {
        if slides.count > 1 {
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                navigate(direction: 1)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func restartTimer() {
        stopTimer()
        startTimer()
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, Memory.self, configurations: config)
    
    let person = Person(name: "Badenur", relation: "Friend", photoData: Data(), embeddingSamples: [])
    container.mainContext.insert(person)
    
    return VStack {
        MemoryStoryCardsView(height: 500)
    }
    .modelContainer(container)
    .background(Color.black)
}
