import SwiftUI
import SwiftData

struct MemoryStoryCardsView: View {
    @Query(sort: \Person.lastInteracted, order: .reverse) var savedPersons: [Person]
    let height: CGFloat
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
        if index == 0 {
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
            .frame(height: height)
            
            // Pagination Dots
            HStack(spacing: 8) {
                ForEach(personsToShow) { person in
                    Circle()
                        .fill(activeID == person.id ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(activeID == person.id ? 1.2 : 1.0)
                        .animation(.spring(), value: activeID)
                }
            }
            .padding(.bottom, 10)
        }
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
            // Background Image
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
                gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Story Progress Pills
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
                
                // Content Overlay
                VStack(alignment: .leading, spacing: 12) {
                    // Name and Relation
                    VStack(alignment: .leading, spacing: 4) {
                        Text(person.name)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text(person.relation)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(.white.opacity(0.2)))
                    }
                    
                    // Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            // Add Memory Action
                        }) {
                            HStack {
                                //                                Image(systemName: "plus")
                                //                                    .font(.system(size: 16, weight: .bold))
                                Text("Add Memory")
                                
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Capsule().fill(.ultraThinMaterial))
                            .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
                            
                        }
                        
                        Button(action: {
                            // View Action
                        }) {
                            Text("View")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Capsule().fill(.ultraThinMaterial))
                                .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Tap areas for navigation
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigate(direction: -1)
                    }
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigate(direction: 1)
                    }
            }
        }
        .frame(width: width, height: height)
        .background(Color.black.opacity(0.1)) // Base background to prevent square look before image loads
        .clipShape(RoundedRectangle(cornerRadius: 32))
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
                currentSlideIndex = 0 // loop back or stay? User said scrolling carousel handles next person
            }
        }
        
        restartTimer()
    }
    
    private func startTimer() {
        // Only auto-advance if not single slide
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
