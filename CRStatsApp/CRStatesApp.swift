//
//  CRStatesApp.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//

import SwiftUI
import SwiftData

@main
struct CRStatsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [SavedPlayer.self, SavedMatch.self])
    }
}
