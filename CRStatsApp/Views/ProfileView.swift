//
//  ProfileView.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/29/25.
//


import SwiftUI

struct ProfileView: View {
    @ObservedObject var playerVM: PlayerViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if let player = playerVM.currentPlayer {
                ScrollView {
                    VStack(spacing: 20) {
                        PlayerHeaderView(player: player)

                        StatsGridView(player: player)
                        
                        if let clan = player.clan {
                            ClanInfoView(clan: clan)
                        }
                        
                        BattleStatsView(player: player)
                        
                        if let league = player.leagueStatistics {
                            LeagueStatsView(league: league)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
                .refreshable {
                    await playerVM.refreshCurrentPlayer()
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("No Player Selected")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Search for a player to view their profile")
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    NavigationLink(destination: Text("Search View")) {
                        Text("Go to Search")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Player Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct PlayerHeaderView: View {
    let player: PlayerDTO
    
    var body: some View {
        VStack(spacing: 12) {
            Text(player.name)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text(player.tag)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
            
            if let expLevel = player.expLevel {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                    Text("Level \(expLevel)")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.yellow)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
        )
    }
}


struct StatsGridView: View {
    let player: PlayerDTO
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            StatCard(
                icon: "trophy.fill",
                title: "Trophies",
                value: "\(player.trophies ?? 0)",
                color: .orange
            )
            
            StatCard(
                icon: "crown.fill",
                title: "Best",
                value: "\(player.bestTrophies ?? 0)",
                color: .yellow
            )
            
            StatCard(
                icon: "checkmark.circle.fill",
                title: "Wins",
                value: "\(player.wins ?? 0)",
                color: .green
            )
            
            StatCard(
                icon: "xmark.circle.fill",
                title: "Losses",
                value: "\(player.losses ?? 0)",
                color: .red
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}
struct ClanInfoView: View {
    let clan: PlayerDTO.ClanSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clan")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            HStack {
                Image(systemName: "person.3.fill")
                    .font(.title2)
                    .foregroundColor(.cyan)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let name = clan.name {
                        Text(name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    if let tag = clan.tag {
                        Text(tag)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}

struct BattleStatsView: View {
    let player: PlayerDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Battle Statistics")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            VStack(spacing: 10) {
                if let threeCrown = player.threeCrownWins {
                    StatRow(icon: "crown.fill", label: "3-Crown Wins", value: "\(threeCrown)", color: .yellow)
                }
                
                if let battleCount = player.battleCount {
                    StatRow(icon: "flame.fill", label: "Total Battles", value: "\(battleCount)", color: .orange)
                }
                
                if let wins = player.wins, let losses = player.losses {
                    let winRate = player.winRate
                    StatRow(
                        icon: "percent",
                        label: "Win Rate",
                        value: String(format: "%.1f%%", winRate),
                        color: winRate >= 50 ? .green : .red
                    )
                }
                
                if let warWins = player.warDayWins {
                    StatRow(icon: "shield.fill", label: "War Wins", value: "\(warWins)", color: .purple)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 25)
            
            Text(label)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

struct LeagueStatsView: View {
    let league: PlayerDTO.LeagueStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("League Statistics")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            VStack(spacing: 10) {
                if let current = league.currentSeason?.trophies {
                    LeagueRow(label: "Current Season", value: current, color: .blue)
                }
                
                if let previous = league.previousSeason?.trophies {
                    LeagueRow(label: "Previous Season", value: previous, color: .cyan)
                }
                
                if let best = league.bestSeason?.trophies {
                    LeagueRow(label: "Best Season", value: best, color: .yellow)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}

struct LeagueRow: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: "trophy.fill")
                .foregroundColor(color)
                .frame(width: 25)
            
            Text(label)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(value)")
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}
