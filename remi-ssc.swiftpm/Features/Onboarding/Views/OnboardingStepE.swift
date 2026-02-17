import SwiftUI

struct OnboardingMockScanView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Binding var isFinished: Bool
    
    // Animation States
    @State private var blurAmount: CGFloat = 20 // Start very blurry
    @State private var scanProgress: CGFloat = 0.0
    @State private var showFaceBox = false
    @State private var showIdentification = false
    @State private var showContinueButton = false
    @State private var isScanning = true
    
    // Mock Data
    private let identifiedName = "Granddaughter"
    
    // Text Animation States
    @State private var textState: Int = 0 // 0: Instruction, 1: Value Prop, 2: Reassurance
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                
                VStack(spacing: sizeClass == .regular ? 0 : 20) {
                    // Top Safe Area for Logo Overlay (Reduced for landscape visibility)
                    Spacer(minLength: sizeClass == .regular ? 40 : 20)
                    
                    // Central Scanning Area
                    ZStack {
                        // The Image (Un-blurring)
                        Image("onboarding-grandmother")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: sizeClass == .regular ? min(geometry.size.width, geometry.size.height) * 0.3 : 220,
                                height: sizeClass == .regular ? min(geometry.size.width, geometry.size.height) * 0.3 : 220
                            )
                            .clipShape(Circle())
                            .blur(radius: blurAmount)
                            .opacity(0.9)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        // Scanning Ring overlay
                        if isScanning {
                            Circle()
                                .trim(from: 0, to: scanProgress)
                                .stroke(
                                    Color("AppPrimary").mix(with: .green, by: scanProgress),
                                    style: StrokeStyle(lineWidth: sizeClass == .regular ? 8 : 4, lineCap: .round)
                                )
                                .frame(
                                    width: sizeClass == .regular ? min(geometry.size.width, geometry.size.height) * 0.35 : 250,
                                    height: sizeClass == .regular ? min(geometry.size.width, geometry.size.height) * 0.35 : 250
                                ) // Slightly larger than image
                                .rotationEffect(.degrees(-90))
                        } else if !showIdentification {
                            // Success Ring (Transient before card shows)
                            Circle()
                                .stroke(Color.green, lineWidth: sizeClass == .regular ? 8 : 4)
                                .frame(
                                    width: sizeClass == .regular ? min(geometry.size.width, geometry.size.height) * 0.35 : 250,
                                    height: sizeClass == .regular ? min(geometry.size.width, geometry.size.height) * 0.35 : 250
                                )
                        }
                    }
                    
                    Spacer() // Push Text to the middle
                    
                    // Psychological / Instructional Text
                    VStack(spacing: 8) {
                        if textState >= 0 {
                            Text("Simply Point Your Camera")
                                .font(.system(sizeClass == .regular ? .title2 : .subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color("AppSecondaryText"))
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                        }
                        
                        if textState >= 1 {
                            Text("And Let The Memories Return.")
                                .font(.system(sizeClass == .regular ? .title : .title2, design: .rounded, weight: .semibold)) // Reduced font size slightly
                                .foregroundStyle(Color("AppPrimaryText"))
                                .multilineTextAlignment(.center)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .frame(height: sizeClass == .regular ? 80 : 60)
                    .padding(.top, sizeClass == .regular ? 0 : 0) // No extra padding needed
                    .animation(.easeInOut, value: textState)
                    
                    Spacer() // Push Footer to bottom (balancing the Text in middle)
                    
                    // Footer (Identified Card + Memories)
                    if showIdentification {
                        VStack(spacing: sizeClass == .regular ? 32 : 16) {
                            // Identified Person Card (Compact)
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(sizeClass == .regular ? .title2 : .title3)
                                    .foregroundStyle(.green)
                                
                                Text("Person Identified: \(identifiedName)")
                                    .font(sizeClass == .regular ? .title3.weight(.medium) : .callout.weight(.medium))
                                    .foregroundStyle(Color("AppPrimaryText"))
                                
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.15), lineWidth: 1)
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            
                            // Single Sentimental Memory
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Shared Moment")
                                    .font(sizeClass == .regular ? .title3 : .subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color("AppSecondaryText"))
                                    .padding(.horizontal, 4)
                                
                                MemoryCard(memory: Memory(content: "Cooking her famous pasta recipe together last Sunday.", type: .general, sentiment: .positive, importance: .high))
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            
                            // Continue Button
                            if showContinueButton {
                                Button(action: {
                                    withAnimation {
                                        hasCompletedOnboarding = true
                                        isFinished = true
                                    }
                                }) {
                                    Text("I'm Ready!")
                                        .font(sizeClass == .regular ? .title3.bold() : .headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity) // Fill available space
                                        .frame(height: sizeClass == .regular ? 64 : 56) // Taller on iPad
                                        .background(Color("AppPrimary"))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .shadow(color: Color("AppPrimary").opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                        .padding(.horizontal, sizeClass == .regular ? geometry.size.width * 0.15 : 20)
                        .padding(.bottom, sizeClass == .regular ? 20 : 30) // Reduced padding for visibility
                    } else {
                        // Placeholder space
                        Color.clear.frame(height: 60)
                    }
                }
            }
        }
        .onAppear {
            runMockScanSequence()
        }
        .navigationBarBackButtonHidden()
    }
    
    private func runMockScanSequence() {
        // 1. Start focusing (unblur) immediately
        withAnimation(.easeInOut(duration: 2.0)) {
            blurAmount = 0
        }
        
        // 2. Simulate scanning progress
        withAnimation(.linear(duration: 2.5)) {
            scanProgress = 1.0
        }
        
        // 2.5 Show "Value Prop" text as blur clears
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                textState = 1
            }
        }
        
        // 3. Identification Success (Switch UI)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isScanning = false
                showIdentification = true
                textState = 2 // Show "Never feel lost again"
            }
            
            // Simple Haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        
        // 4. Show Continue Button shortly after card appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                showContinueButton = true
            }
        }
    }
}

#Preview() {
    @State var isFinished: Bool = false
    OnboardingMockScanView(isFinished: $isFinished)
}
