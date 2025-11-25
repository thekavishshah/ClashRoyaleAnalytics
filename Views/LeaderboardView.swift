//
//  LeaderboardView.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/29/25.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var viewModel: LeaderboardViewModel
    @State private var showingLocationPicker = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.yellow.opacity(0.6), Color.orange.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                        
                        Text("Top Players")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { showingLocationPicker = true }) {
                            HStack(spacing: 4) {
                                Text(locationDisplayName)
                                    .font(.subheadline)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .background(Color.white.opacity(0.1))
                
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Loading leaderboard...")
                            .foregroundColor(.white)
                            .padding(.top)
                        Spacer()
                    }
                } else if let error = viewModel.errorMessage {
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
                            Task {
                                await viewModel.refreshLeaderboard()
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(10)
                        Spacer()
                    }
                } else if viewModel.topPlayers.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        Text("No Players Found")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(Array(viewModel.topPlayers.enumerated()), id: \.element.id) { index, player in
                            LeaderboardRow(player: player, rank: index + 1)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.topPlayers.isEmpty {
                await viewModel.fetchTopPlayers()
            }
            if viewModel.locations.isEmpty {
                await viewModel.fetchLocations()
            }
        }
        .refreshable {
            await viewModel.refreshLeaderboard()
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(
                viewModel: viewModel,
                isPresented: $showingLocationPicker
            )
        }
    }
    
    private var locationDisplayName: String {
        if viewModel.selectedLocation == "global" {
            return "🌍 Global"
        }
        if let location = viewModel.locations.first(where: { String($0.id) == viewModel.selectedLocation }) {
            return location.displayName
        }
        return "Select Region"
    }
}

struct LeaderboardRow: View {
    let player: TopPlayerDTO
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 50, height: 50)
                
                Text("#\(rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(player.tag)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    if let clan = player.clan, let clanName = clan.name {
                        HStack(spacing: 2) {
                            Image(systemName: "person.3.fill")
                                .font(.caption2)
                            Text(clanName)
                                .font(.caption)
                        }
                        .foregroundColor(.cyan)
                        .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("\(player.trophies ?? 0)")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                
                if let prevRank = player.previousRank {
                    let change = prevRank - player.rank
                    HStack(spacing: 2) {
                        Image(systemName: change > 0 ? "arrow.up" : (change < 0 ? "arrow.down" : "minus"))
                        Text("\(abs(change))")
                    }
                    .font(.caption)
                    .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .gray))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(rank <= 3 ? 0.25 : 0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rank <= 3 ? rankColor : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue.opacity(0.7)
        }
    }
}

struct LocationPickerView: View {
    @ObservedObject var viewModel: LeaderboardViewModel
    @Binding var isPresented: Bool
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    Task {
                        await viewModel.fetchTopPlayers(location: "global")
                        isPresented = false
                    }
                }) {
                    HStack {
                        Text("🌍 Global")
                            .foregroundColor(.primary)
                        Spacer()
                        if viewModel.selectedLocation == "global" {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                ForEach(filteredLocations) { location in
                    Button(action: {
                        Task {
                            await viewModel.fetchTopPlayers(location: String(location.id))
                            isPresented = false
                        }
                    }) {
                        HStack {
                            Text(location.displayName)
                                .foregroundColor(.primary)
                            Spacer()
                            if viewModel.selectedLocation == String(location.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search countries")
            .navigationTitle("Select Region")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private var filteredLocations: [ClashAPI.Location] {
        if searchText.isEmpty {
            return viewModel.locations
        }
        return viewModel.locations.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}
