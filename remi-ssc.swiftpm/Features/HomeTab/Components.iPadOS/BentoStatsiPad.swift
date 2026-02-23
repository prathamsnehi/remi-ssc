import SwiftUI

struct BentoStatsiPad: View {
    let height: CGFloat
    // Placeholder Data
    let lovedOnesCount = 12
    let memoriesCount = 148
    let daysCount = 42
    
    var body: some View {
        HStack(spacing: 12) {
            // 1. Loved Ones Registered
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "heart.fill")
                    .foregroundColor(Color("AppPrimary"))
                Text("\(lovedOnesCount) Loved Ones Registered")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("AppPrimaryText"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color("AppSurface").opacity(0.8))
            .cornerRadius(20)
            
            // 2. Memories Recounted
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(Color("AppPrimary"))
                Text("\(memoriesCount) Memories Recounted")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("AppPrimaryText"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color("AppSurface").opacity(0.8))
            .cornerRadius(20)
            
            // 3. Soothing Usage Streak
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(Color("AppPrimary"))
                Text("\(daysCount) Days of Mindful Presence")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("AppPrimaryText"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color("AppSurface").opacity(0.8))
            .cornerRadius(20)
        }
        .frame(height: height) // Keeps it as a single "row" component
//        .padding(.horizontal)
    }
}
