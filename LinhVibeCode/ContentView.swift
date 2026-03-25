//
//  ContentView.swift
//  LinhVibeCode
//
//  Created by ThanhHV-NEOS068 on 24/3/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore()

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Projects", systemImage: "folder.fill") }

            MemberListView()
                .tabItem { Label("Members", systemImage: "person.2.fill") }
        }
        .environmentObject(store)  // single injection point for the whole app
    }
}

#Preview {
    ContentView()
}
