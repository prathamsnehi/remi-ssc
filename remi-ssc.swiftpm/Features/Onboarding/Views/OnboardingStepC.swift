import SwiftUI

struct OnboardingStruggleView: View {
    @Binding var path: NavigationPath // Changed to path for navigation to Step D
    
    @State private var bubbles: [ThoughtBubble] = []
    @State private var showButton = false
    
    // Thoughts to cycle through
    private let thoughts = [
        "Who is that?",
        "I know them...",
        "Name?",
        "Is it Mary?",
        "So embarrassing",
        "Just smile",
        "Don't ask me",
        "On the tip of my tongue",
        "Sarah?",
        "I feel terrible",
        "Wait...",
    ]
    
    struct ThoughtBubble: Identifiable {
        let id = UUID()
        let text: String
        var xOffset: CGFloat
        var scale: CGFloat
        var isVisible: Bool = false
    }
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            // Content Container
            VStack {
                // Header Text
                Text("Ever had these thoughts before talking to one of your loved ones?")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color("AppPrimaryText"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 60)
                
                // Center Content
                Spacer()
                
                // Bubbles Stack
                FlowLayout(spacing: 12) {
                    ForEach($bubbles) { $bubble in
                        Text(bubble.text)
                            .font(.system(.body, design: .rounded, weight: .medium))
                            .foregroundStyle(Color("AppSecondaryText"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
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
                .padding(.horizontal, 16)
                .scaleEffect(y: -1) // Flip container
                
                Spacer()
                Color.clear.frame(height: 60) // Space for button
            }
            .zIndex(1)
            
            // Button Anchored at Bottom
            VStack {
                Spacer()
                if showButton {
                    Button(action: {
                        path.append("facescan")
                    }) {
                        Text("Yes, but want to overcome them")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("AppPrimary"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color("AppPrimary").opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                    .transition(.opacity.animation(.easeIn(duration: 1.0)))
                }
            }
            .zIndex(3)
        }
        .onAppear {
            prepareBubbles()
            startBubbleStream()
        }
        .navigationBarBackButtonHidden()
    }
    
    private func prepareBubbles() {
        if bubbles.isEmpty {
            for text in thoughts {
                let scale = CGFloat.random(in: 0.95...1.05)
                let bubble = ThoughtBubble(text: text, xOffset: 0, scale: scale, isVisible: false)
                bubbles.append(bubble)
            }
        }
    }
    
    private func startBubbleStream() {
        var delay = 0.5
        
        for index in bubbles.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                bubbles[index].isVisible = true
                
                // Simple Haptic
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            delay += 0.15
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
