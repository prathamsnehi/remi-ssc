//
//  HomeActionButtons.swift
//  remi
//
//  Created by Pratham S on 12/22/25.
//

import SwiftUI

struct HomeActionButtons: View {
    // We use closures (callbacks) so the parent view handles the actual navigation
    var onRegisterTap: () -> Void
    var onIdentifyTap: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Button A: Register / Meet
            SelectionButton(
                title: "New\nFriend",
                icon: "person.badge.plus.fill",
                backgroundColor: .blue,
                foregroundColor: .white,
                height: 120,
                titleFont: .headline,
                iconFont: .largeTitle,
                action: onRegisterTap
            )
            
            // Button B: Identify
            SelectionButton(
                title: "Identify\nPerson",
                icon: "person.fill.questionmark",
                backgroundColor: Color("AppPrimary"),
                foregroundColor: .white,
                height: 120,
                titleFont: .headline,
                iconFont: .largeTitle,
                action: onIdentifyTap
            )
        }
        .padding(.horizontal)
    }
}

// Internal helper just for this file
// Removed ActionButton struct as we are now using SelectionButton

