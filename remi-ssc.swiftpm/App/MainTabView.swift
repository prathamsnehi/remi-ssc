//
//  MainTabView.swift
//  remi-ssc
//
//  Created by Pratham S on 2/6/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            
            Tab("Friends", systemImage: "person.2.fill") {
                SavedFriendsView()
            }
        }
        
    }
}
