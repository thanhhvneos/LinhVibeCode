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
        DashboardView()
            .environmentObject(store)
    }
}

#Preview {
    ContentView()
}
