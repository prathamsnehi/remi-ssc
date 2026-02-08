//
//  StubView.swift
//  remi copy
//
//  Created by Pratham S on 1/15/26.
//

import SwiftUI

struct StubView: View {
    let title: String
    let iconName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundStyle(Color("AppSecondaryText"))
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color("AppPrimaryText"))
            
            Text("This feature is coming soon.")
                .font(.subheadline)
                .foregroundStyle(Color("AppSecondaryText"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground"))
    }
}

#Preview {
    StubView(title: "Preferences", iconName: "gear")
}
