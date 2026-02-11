import SwiftUI

struct OnboardingMockScanView: View {
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
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Central Scanning Area
                ZStack {
                    // The Image (Un-blurring)
                    Image("onboarding-grandmother")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 220, height: 220)
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
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 250, height: 250) // Slightly larger than image
                            .rotationEffect(.degrees(-90))
                    } else if !showIdentification {
                        // Success Ring (Transient before card shows)
                        Circle()
                            .stroke(Color.green, lineWidth: 4)
                            .frame(width: 250, height: 250)
                    }
                }
                
                // Psychological / Instructional Text (Moved Below)
                VStack(spacing: 12) {
                    if textState >= 0 {
                        Text("Simply Point Your Camera")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color("AppSecondaryText"))
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    }
                    
                    if textState >= 1 {
                        Text("And Let The Memories Return.")
                            .font(.system(.title2, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color("AppPrimaryText"))
                            .multilineTextAlignment(.center)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .frame(height: 60)
                .animation(.easeInOut, value: textState)
                

                
                // Footer (Identified Card + Memories)
                if showIdentification {
                    VStack(spacing: 16) {
                        // Identified Person Card
                        HStack(spacing: 16) {
                            Image("onboarding-grandmother")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(identifiedName)
                                    .font(.title3.bold())
                                    .foregroundStyle(Color("AppPrimaryText"))
                                
                                Text("Family")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppSecondaryText"))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                        }
                        .padding(16)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.15), lineWidth: 1)
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        // Single Sentimental Memory
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shared Moment")
                                .font(.subheadline)
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
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color("AppPrimary"))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: Color("AppPrimary").opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                } else {
                    // Placeholder space
                    Color.clear.frame(height: 60)
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

#Preview {
    @State var isFinished: Bool = false
    OnboardingMockScanView(isFinished: $isFinished)
}
