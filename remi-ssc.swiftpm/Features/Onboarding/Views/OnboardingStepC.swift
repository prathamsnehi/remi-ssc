import SwiftUI

struct OnboardingStruggleView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Binding var path: NavigationPath // Changed to path for navigation to Step D
    
    @State private var bubbles: [ThoughtBubble] = []
    @State private var showButton = false
    
    // Thoughts to cycle through
    private let thoughts = [
        "Who Is That?", "I Know Them...", "Name?",
        "Is It Mary?", "So Embarrassing", "Just Smile",
        "Don't Ask Me", "On The Tip Of My Tongue", "Sarah?",
        "I Feel Terrible", "Wait..."
    ]
    
    // iPad specific thoughts (more density)
    private let ipadThoughts = [
        "Who Is That?", "I Know Them...", "Name?", "Is It Mary?",
        "So Embarrassing", "Just Smile", "Don't Ask Me",
        "On The Tip Of My Tongue", "Sarah?", "I Feel Terrible",
        "Wait...", "Why Can't I Remember?", "It's Been Years",
        "They Look Familiar", "Help Me", "What Was It?"
        ]
    
    struct ThoughtBubble: Identifiable {
        let id = UUID()
        let text: String
        var xOffset: CGFloat
        var scale: CGFloat
        var isVisible: Bool = false
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()
                
                // Content Container
                VStack {
                    // Center Content
                    Spacer()
                    Spacer() // Double spacer to push content lower
                    
                    // Bubbles Stack
                    FlowLayout(spacing: sizeClass == .regular ? 20 : 12) {
                        ForEach($bubbles) { $bubble in
                            Text(bubble.text)
                                .font(.system(sizeClass == .regular ? .title3 : .body, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color("AppSecondaryText"))
                                .padding(.horizontal, sizeClass == .regular ? 24 : 16)
                                .padding(.vertical, sizeClass == .regular ? 16 : 12)
                                .background(
                                    Capsule()
                                        .fill(Color("AppSurface"))
                                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                )
                                .scaleEffect(bubble.scale)
                                .scaleEffect(y: -1) // Unflip
                                .opacity(bubble.isVisible ? 1 : 0)
                                .scaleEffect(bubble.isVisible ? 1 : 0.5)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: bubble.isVisible)
                        }
                    }
                    .padding(.horizontal, sizeClass == .regular ? geometry.size.width * 0.15 : 16)
                    .scaleEffect(y: -1) // Flip container
                    
                    // Header Text (Moved Below)
                    Text("Ever Had These Thoughts Before Talking To A Loved One?")
                        .font(.system(sizeClass == .regular ? .largeTitle : .title2, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color("AppPrimaryText"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.top, sizeClass == .regular ? 60 : 40) // Breathing room
                        .padding(.bottom, 20)
                    
                    
                    Spacer()
                    Color.clear.frame(height: sizeClass == .regular ? 120 : 80)
                }
                .zIndex(1)
                
                // Button Anchored at Bottom
                VStack {
                    Spacer()
                    if showButton {
                        Button(action: {
                            path.append("facescan")
                        }) {
                            Text("Yes, But I Want To Overcome Them")
                                .font(.system(size: sizeClass == .regular ? 24 : 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity) // Fill available space
                                .frame(height: sizeClass == .regular ? 64 : 56) // Taller on iPad
                                .background(Color("AppPrimary"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color("AppPrimary").opacity(0.3), radius: 10, x: 0, y: 5)
                                .padding(.horizontal, sizeClass == .regular ? geometry.size.width * 0.15 : 20)
                                .padding(.bottom, sizeClass == .regular ? 40 : 20)
                        }
                        .transition(.opacity.animation(.easeIn(duration: 1.0)))
                    }
                }
                .zIndex(3)
            }
        }
        .onAppear {
            // We can't easily pass geometry here without a binding or preferences, 
            // but for a simpler fix let's rely on UIDevice or just assume standard start.
            // Actually, we can use a small hack or just check screen bounds if geometry isn't available in onAppear directly contexts.
            // Better: use the sizeClass to determine iPad, and for landscape/portrait check Main bounds or just proceed.
            // Since we need to be accurate about "landscape", let's use the UIScreen main bounds as a proxy if needed, 
            // or better, just pass the logic into a helper that runs on the first frame if possible.
            // HOWEVER, the cleanest SwiftUI way is using .task or just checking geometry in a proper way.
            // Given the constraints, I will assume the view loads.
            // Let's use a Task to allow geometry to propagate if needed, but onAppear is fine.
            // I'll check horizontal/vertical sizing via UIScreen for simple orientation check if geometry isn't passed.
            // Actually, let's just use the geometry reader's values inside an onChange or similar? No, complicate.
            // Simple approach: Use UIDevice orientation or Screen bounds.
            let isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
            prepareBubbles(isLandscape: isLandscape)
            startBubbleStream()
        }
        .navigationBarBackButtonHidden()
    }
    
    private func prepareBubbles(isLandscape: Bool) {
        if bubbles.isEmpty {
            var ideas = sizeClass == .regular ? ipadThoughts : thoughts
            
            // iPad Landscape Refinement: Reduce by exactly 2
            if sizeClass == .regular && isLandscape {
                ideas = Array(ideas.dropLast(2))
            }
            
            for text in ideas {
                let scale = CGFloat.random(in: 0.95...1.05)
                let bubble = ThoughtBubble(text: text, xOffset: 0, scale: scale, isVisible: false)
                bubbles.append(bubble)
            }
        }
    }
    
    private func startBubbleStream() {
        // iPad Refinement: Faster speed for iPad (0.1 vs 0.15)
        var delay = 0.5
        let increment = sizeClass == .regular ? 0.1 : 0.15
        
        for index in bubbles.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if index < bubbles.count { // Safety check
                    bubbles[index].isVisible = true
                    
                    // Simple Haptic
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
            delay += increment
        }
        
        // Show Button after bubbles
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
            withAnimation {
                showButton = true
            }
        }
    }
}

// Simple Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.height }.reduce(0, +) + CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            let rowContentWidth = row.items.map { $0.sizeThatFits(.unspecified).width }.reduce(0, +) + CGFloat(max(0, row.items.count - 1)) * spacing
            let xStart = bounds.minX + (bounds.width - rowContentWidth) / 2
            
            var x = xStart
            for item in row.items {
                item.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += item.sizeThatFits(.unspecified).width + spacing
            }
            y += row.height + spacing
        }
    }
    
    struct Row {
        var items: [LayoutSubview]
        var height: CGFloat
    }
    
    func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow: [LayoutSubview] = []
        var currentX: CGFloat = 0
        var currentHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && !currentRow.isEmpty {
                rows.append(Row(items: currentRow, height: currentHeight))
                currentRow = []
                currentX = 0
                currentHeight = 0
            }
            currentRow.append(view)
            currentX += size.width + spacing
            currentHeight = max(currentHeight, size.height)
        }
        if !currentRow.isEmpty {
            rows.append(Row(items: currentRow, height: currentHeight))
        }
        return rows
    }
}

#Preview {
    @State var path = NavigationPath()
    OnboardingStruggleView(path: $path)
}
