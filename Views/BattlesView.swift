//
//  BattlesView.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/29/25.
//


import SwiftUI
import SwiftData

struct BattlesView: View {
    @ObservedObject var playerVM: PlayerViewModel
    @ObservedObject var battleVM: BattleViewModel
    let onSaveMatch: (BattleDTO, String) -> Void
    
    @Query(sort: \SavedMatch.savedAt, order: .reverse) private var savedMatches: [SavedMatch]
    @State private var showingSavedMatches = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange.opacity(0.6), Color.red.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if !battleVM.battles.isEmpty {
                    BattleStatsHeader(battleVM: battleVM)
                        .padding()
                }
                
                Picker("View", selection: $showingSavedMatches) {
                    Text("Recent Battles").tag(false)
                    Text("Saved (\(savedMatches.count))").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                if showingSavedMatches {
                    SavedMatchesListView(matches: savedMatches)
                } else {
                    RecentBattlesListView(
                        battleVM: battleVM,
                        playerVM: playerVM,
                        onSaveMatch: onSaveMatch
                    )
                }
            }
        }
        .navigationTitle("Battle Log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let player = playerVM.currentPlayer, !battleVM.isLoading {
                    Button(action: {
                        Task {
                            await battleVM.refreshBattles(for: player.tag)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .task {
            if let player = playerVM.currentPlayer {
                await battleVM.fetchBattles(for: player.tag)
            }
        }
    }
}


struct BattleStatsHeader: View {
    @ObservedObject var battleVM: BattleViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            StatsColumn(
                title: "Wins",
                value: "\(battleVM.winCount)",
                color: .green
            )
            
            Divider()
                .frame(height: 50)
                .background(Color.white.opacity(0.3))
            
            StatsColumn(
                title: "Losses",
                value: "\(battleVM.lossCount)",
                color: .red
            )
            
            Divider()
                .frame(height: 50)
                .background(Color.white.opacity(0.3))
            
            StatsColumn(
                title: "Win Rate",
                value: String(format: "%.1f%%", battleVM.winRate),
                color: .yellow
            )
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}

struct StatsColumn: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}


struct RecentBattlesListView: View {
    @ObservedObject var battleVM: BattleViewModel
    @ObservedObject var playerVM: PlayerViewModel
    let onSaveMatch: (BattleDTO, String) -> Void
    
    var body: some View {
        if battleVM.isLoading {
            VStack {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Loading battles...")
                    .foregroundColor(.white)
                    .padding(.top)
                Spacer()
            }
        } else if let error = battleVM.errorMessage {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                Text(error)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("Try Again") {
                    if let player = playerVM.currentPlayer {
                        Task {
                            await battleVM.refreshBattles(for: player.tag)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(10)
                Spacer()
            }
        } else if battleVM.battles.isEmpty {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.5))
                Text("No Battles Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("Search for a player to view their battle history")
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
        } else {
            List {
                ForEach(battleVM.battles) { battle in
                    BattleRow(battle: battle, onSave: {
                        if let playerTag = playerVM.currentPlayer?.tag {
                            onSaveMatch(battle, playerTag)
                        }
                    })
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}


struct BattleRow: View {
    let battle: BattleDTO
    let onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(resultColor)
                    .frame(width: 12, height: 12)
                
                Text(battle.battleTypeDisplay)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onSave) {
                    Image(systemName: "bookmark")
                        .foregroundColor(.white)
                }
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(battle.team.first?.name ?? "You")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(battle.team.first?.crowns ?? 0)")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                
                Text("VS")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(battle.opponent.first?.name ?? "Opponent")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("\(battle.opponent.first?.crowns ?? 0)")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                if let trophyChange = battle.team.first?.trophyChange {
                    HStack(spacing: 2) {
                        Image(systemName: trophyChange >= 0 ? "arrow.up" : "arrow.down")
                        Text("\(abs(trophyChange))")
                    }
                    .font(.caption)
                    .foregroundColor(trophyChange >= 0 ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            
            Text(battle.formattedDate)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
    
    private var resultColor: Color {
        if battle.isVictory {
            return .green
        } else if battle.isDraw {
            return .yellow
        } else {
            return .red
        }
    }
}


struct SavedMatchesListView: View {
    let matches: [SavedMatch]
    
    var body: some View {
        if matches.isEmpty {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "bookmark")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.5))
                Text("No Saved Matches")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("Save matches from recent battles to view them here")
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
        } else {
            List {
                ForEach(matches) { match in
                    SavedMatchRow(match: match)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

struct SavedMatchRow: View {
    let match: SavedMatch
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(match.isVictory ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                
                Text(match.battleType)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(match.resultDisplay)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(match.isVictory ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
            
            HStack {
                Text("vs \(match.opponentName)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(match.scoreDisplay)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
}
