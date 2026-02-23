import SwiftUI
import SwiftData


struct BentoStatsiPad: View {
    let height: CGFloat
    
    @Query var savedPersons: [Person]
    @Query var appMetadata: [Metadata]
    
    func getDaysSinceAppStart () -> Int {
        let calendar = Calendar.current
        guard let metadata = appMetadata.first else {
            return 0
        }
        let appStartDate = calendar.startOfDay(for: metadata.appStartDate)
        let differences = calendar.dateComponents([.day], from: appStartDate, to: .now)
        return differences.day ?? 0
    }
    
    var lovedOnesCount: Int {
        savedPersons.count
    }
    
    var memoriesCount: Int {
        savedPersons.reduce(0) { $0 + $1.memories.count }
    }
    
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            // Use the smaller dimension to prevent blowing up bounds when width is huge but height is constrained
            let scaleRef = min(w * 0.5, h * 1.5)
            
            HStack(spacing: 0) {
                // 1. Loved Ones Registered
                StatItem(icon: "heart.fill", value: "\(lovedOnesCount)", label: "Loved Ones\nRegistered", scaleRef: scaleRef)
                
                Divider()
                    .padding(.vertical, height * 0.25)
                
                // 2. Memories Recounted
                StatItem(icon: "sparkles", value: "\(memoriesCount)", label: "Memories\nRecounted", scaleRef: scaleRef)
                
                Divider()
                    .padding(.vertical, height * 0.25)
                
                // 3. Soothing Usage Streak
                StatItem(icon: "moon.stars.fill", value: "\(getDaysSinceAppStart())", label: "Days of\nApp Use", scaleRef: scaleRef)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AppSurface"))
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 15, y: 8)
        }
        .frame(height: height) 
    }
}

fileprivate struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let scaleRef: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: max(16, scaleRef * 0.08)) {
            Image(systemName: icon)
                .font(.system(size: max(38, scaleRef * 0.16))) // Increased icon size per request
                .foregroundColor(Color("AppPrimary"))
            
            VStack(alignment: .leading, spacing: max(4, scaleRef * 0.015)) {
                Text(value)
                    .font(.system(size: max(24, scaleRef * 0.12), weight: .bold, design: .rounded))
                    .foregroundColor(Color("AppPrimaryText"))
                
                Text(label)
                    .font(.system(size: max(12, scaleRef * 0.07), weight: .medium))
                    .foregroundColor(Color("AppSecondaryText"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
