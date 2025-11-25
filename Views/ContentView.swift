//
//  ContentView.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//


import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedPlayer.savedAt, order: .reverse) private var savedPlayers: [SavedPlayer]
    
    @StateObject private var playerVM = PlayerViewModel()
    @StateObject private var battleVM = BattleViewModel()
    @StateObject private var leaderboardVM = LeaderboardViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                SearchView(
                    playerVM: playerVM,
                    savedPlayers: savedPlayers,
                    onSavePlayer: savePlayer
                )
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(0)
            
            NavigationStack {
                ProfileView(playerVM: playerVM)
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle.fill")
            }
            .tag(1)
            
            NavigationStack {
                BattlesView(
                    playerVM: playerVM,
                    battleVM: battleVM,
                    onSaveMatch: saveMatch
                )
            }
            .tabItem {
                Label("Battles", systemImage: "list.bullet.rectangle.fill")
            }
            .tag(2)
            
            NavigationStack {
                LeaderboardView(viewModel: leaderboardVM)
            }
            .tabItem {
                Label("Top Players", systemImage: "trophy.fill")
            }
            .tag(3)
            
            NavigationStack {
                WorldMapView(
                    leaderboardVM: leaderboardVM,
                    locationManager: locationManager
                )
            }
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            .tag(4)
        }
        .accentColor(.blue)
    }
    
    
    private func savePlayer(_ player: PlayerDTO) {
        let savedPlayer = SavedPlayer(
            tag: player.tag,
            name: player.name,
            trophies: player.trophies ?? 0
        )
        modelContext.insert(savedPlayer)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving player: \(error)")
        }
    }
    
    private func saveMatch(_ battle: BattleDTO, playerTag: String) {
        guard let playerTeam = battle.team.first,
              let opponentTeam = battle.opponent.first else { return }
        
        let savedMatch = SavedMatch(
            battleTime: battle.battleTime,
            playerTag: playerTag,
            opponentName: opponentTeam.name ?? "Unknown",
            playerCrowns: playerTeam.crowns ?? 0,
            opponentCrowns: opponentTeam.crowns ?? 0,
            isVictory: battle.isVictory,
            battleType: battle.battleTypeDisplay,
            trophyChange: playerTeam.trophyChange
        )
        
        modelContext.insert(savedMatch)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving match: \(error)")
        }
    }
}
