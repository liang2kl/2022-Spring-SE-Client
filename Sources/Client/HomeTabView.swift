//
//  HomeTabView.swift
//  Client
//
//  Created by liang2kl on 2022/5/9.
//

import SwiftUI

struct HomeTabView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}
