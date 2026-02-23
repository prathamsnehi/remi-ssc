import SwiftUI
import SwiftData

struct MemoryStoryCardsiPadView: View {
    @Query(sort: \Person.lastInteracted, order: .reverse) var savedPersons: [Person]
    let height: CGFloat
    var onScanFace: (() -> Void)? = nil
    let maxCardsDisplayed = 5
    
    // iPad-specific dynamic card width
    private var cardWidth: CGFloat {
        height * 0.85
    }
    
    @State private var activeID: UUID?
    
    private var personsToShow: [Person] {
        Array(savedPersons.prefix(maxCardsDisplayed))
    }
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { proxy in
                
                if personsToShow.isEmpty {
                    VStack {
                        Spacer()
                        PlaceholderMemoryCard(width: proxy.size.width - 80, height: height, action: onScanFace)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    let cardWidth = proxy.size.width * 0.65 // iPad card width proportion
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(personsToShow) { person in
                                MemoryStoryCardiPad(
                                    person: person,
                                    width: cardWidth,
                                    height: height
                                )
                                .id(person.id)
                            }
                            
                            if personsToShow.count == 1 {
                                let remainingWidth = proxy.size.width - cardWidth - 16
                                MinimalAddPersonCardiPad(width: remainingWidth, height: height, action: onScanFace)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $activeID)
                    .onAppear {
                        if activeID == nil {
                            activeID = personsToShow.first?.id
                        }
                    }
                }
            }
            .frame(height: height)
            
            // Pagination Dots
            if !personsToShow.isEmpty {
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
}

struct MemoryStoryCardiPad: View {
    let person: Person
    let width: CGFloat
    let height: CGFloat
    
    // Extract the latest memory text (ignoring photos)
    private var latestMemoryText: String? {
        // Find the last memory that has textual content (either title or content)
        if let memory = person.memories.last(where: { !$0.content.isEmpty || !$0.content.isEmpty }) {
            return memory.content.isEmpty ? memory.content : memory.content
        }
        return nil
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            RoundedRectangle(cornerRadius: 32)
                .fill(Color("AppSurface"))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
            
            // Invisible Navigation Link covering the entire card
            NavigationLink(destination: FriendProfileView(person: person)) {
                Color.clear
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 24) {
                // Header Sequence: Avatar (Left), Name & Relation (Right)
                HStack(alignment: .center, spacing: 24) {
                    // Profile Image
                    if let uiImage = UIImage(data: person.photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.gray.opacity(0.5))
                            )
                    }
                    
                    // Name and Relation
                    VStack(alignment: .leading, spacing: 8) {
                        Text(person.name)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppPrimaryText"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Text(person.relation)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color("AppPrimaryText").opacity(0.8))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.primary.opacity(0.08)))
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Latest Memory Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Latest Memory")
                        .font(.headline)
                        .foregroundStyle(Color("AppSecondaryText"))
                        .textCase(.uppercase)
                    
                    if let memoryText = latestMemoryText, !memoryText.isEmpty {
                        Text(memoryText)
                            .font(.system(size: 22, design: .serif))
                            .italic()
                            .foregroundStyle(Color("AppPrimaryText"))
                            .lineSpacing(4)
                            .lineLimit(5)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Click to add memories to remember them")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundStyle(Color("AppSecondaryText").opacity(0.8))
                            .italic()
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(40) // Generous iPad padding
            .allowsHitTesting(false) // Let clicks pass down to NavigationLink
            
            // "Add Memory" Button Overlay (Top Right absolute positioning)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // Add Memory Action
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color("AppPrimary"))
                            .frame(width: 56, height: 56)
                            .background(Color("AppSurface"))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .overlay(Circle().stroke(Color.primary.opacity(0.05), lineWidth: 1))
                    }
                    .padding(24) // Float in the corner
                }
                Spacer()
            }
        }
        .frame(width: width, height: height)
        .shadow(color: .black.opacity(0.04), radius: 15, y: 8)
    }
}

struct MinimalAddPersonCardiPad: View {
    let width: CGFloat
    let height: CGFloat
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color("AppSurface").opacity(0.5)) // Slightly transparent to feel like a placeholder
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.primary.opacity(0.1), style: StrokeStyle(lineWidth: 2, dash: [8]))
                    )
                
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 40))
                        .foregroundStyle(Color("AppPrimary").opacity(0.8))
                    
                    Text("Add more people")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(Color("AppSecondaryText"))
                }
            }
            .frame(width: width, height: height)
        }
        .buttonStyle(.plain)
    }
}
