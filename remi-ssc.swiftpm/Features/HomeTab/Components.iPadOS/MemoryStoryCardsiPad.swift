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
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            // Scale reference based on min of width and height, prioritizing width heavily
            let scaleRef = min(w * 0.8, h * 1.2)
            
            // Proportional layout sizes
            let avatarSize = max(60, scaleRef * 0.25)
            let nameFontSize = max(24, scaleRef * 0.08)
            let relationFontSize = max(12, scaleRef * 0.04)
            let memoryFontSize = max(16, scaleRef * 0.06)
            let headerSpacing = max(4, scaleRef * 0.02)
            
            VStack(alignment: .leading, spacing: max(16, scaleRef * 0.05)) {
                // Header Sequence: Avatar (Left), Name & Relation (Right)
                HStack(alignment: .center, spacing: max(16, scaleRef * 0.06)) {
                    // Profile Image
                    if let uiImage = UIImage(data: person.photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: avatarSize, height: avatarSize)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: avatarSize, height: avatarSize)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: avatarSize * 0.45))
                                    .foregroundStyle(Color.gray.opacity(0.5))
                            )
                    }
                    
                    // Name and Relation
                    VStack(alignment: .leading, spacing: headerSpacing) {
                        Text(person.name)
                            .font(.system(size: nameFontSize, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppPrimaryText"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Text(person.relation)
                            .font(.system(size: relationFontSize, weight: .semibold, design: .default))
                            .foregroundStyle(Color("AppPrimaryText").opacity(0.8))
                            .padding(.horizontal, max(12, scaleRef * 0.035))
                            .padding(.vertical, max(6, scaleRef * 0.018))
                            .background(Capsule().fill(Color.primary.opacity(0.08)))
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .padding(.vertical, max(2, scaleRef * 0.01))
                
                // Latest Memory Section
                VStack(alignment: .leading, spacing: max(6, scaleRef * 0.02)) {
                    Text("LATEST MEMORY")
                        .font(.system(size: max(10, scaleRef * 0.03), weight: .bold))
                        .foregroundStyle(Color("AppSecondaryText"))
                    
                    if let memoryText = latestMemoryText, !memoryText.isEmpty {
                        Text(memoryText)
                            .font(.system(size: memoryFontSize, design: .serif))
                            .italic()
                            .foregroundStyle(Color("AppPrimaryText"))
                            .lineSpacing(max(2, scaleRef * 0.01))
                            .lineLimit(4)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Click to add memories to remember them")
                            .font(.system(size: max(14, scaleRef * 0.045), weight: .medium, design: .rounded))
                            .foregroundStyle(Color("AppSecondaryText").opacity(0.8))
                            .italic()
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, max(24, scaleRef * 0.08))
            .padding(.top, max(24, scaleRef * 0.08))
            .padding(.bottom, max(16, scaleRef * 0.06))
            .frame(width: width, height: height, alignment: .top) // Enforce strict dimensions on the VStack container itself
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color("AppSurface"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
            )

            // Total Card Tap area Navigation
            .overlay {
                NavigationLink(destination: FriendProfileView(person: person)) {
                    Color.clear.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .clipped() // Ensures overflow content doesn't bleed out of bounds
            .shadow(color: .black.opacity(0.04), radius: 15, y: 8)
        }
        .frame(width: width, height: height)
    }
}

