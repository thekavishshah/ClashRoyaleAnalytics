//
//  ContentView.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \SavedPlayer.savedAt, order: .reverse) private var saved: [SavedPlayer]
    @StateObject private var vm = PlayerViewModel()
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { SearchView(vm: vm, onSave: { p in
                let s = SavedPlayer(tag: p.tag, name: p.name)
                ctx.insert(s)
            }, saved: saved) }.tabItem { Image(systemName: "magnifyingglass"); Text("Search") }.tag(0)
            NavigationStack { ProfileView(vm: vm) }.tabItem { Image(systemName: "person"); Text("Profile") }.tag(1)
            NavigationStack { BattlesView(vm: vm) }.tabItem { Image(systemName: "list.bullet.rectangle"); Text("Battles") }.tag(2)
            NavigationStack { LeaderboardView() }.tabItem { Image(systemName: "trophy"); Text("Top") }.tag(3)
            NavigationStack { WorldMapView() }.tabItem { Image(systemName: "map"); Text("Map") }.tag(4)
        }
    }
}
