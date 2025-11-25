//
//  SearchView.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.

import SwiftUI
import SwiftData

struct SearchView: View {
    @ObservedObject var playerVM: PlayerViewModel
    let savedPlayers: [SavedPlayer]
    let onSavePlayer: (PlayerDTO) -> Void
    
    @State private var searchTag = ""
    @State private var showingSavedPlayers = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Search Players")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Enter Player Tag (e.g., #ABC123)", text: $searchTag)
                            .textFieldStyle(.plain)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                        
                        if !searchTag.isEmpty {
                            Button(action: { searchTag = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    
                    Button(action: searchPlayer) {
                        HStack {
                            if playerVM.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Search")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(searchTag.isEmpty || playerVM.isLoading)
                }
                .padding(.horizontal)
                
                if let error = playerVM.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(error)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                if !savedPlayers.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Saved Players")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: { showingSavedPlayers.toggle() }) {
                                Image(systemName: showingSavedPlayers ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        
                        if showingSavedPlayers {
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(savedPlayers.prefix(10)) { player in
                                        SavedPlayerRow(player: player) {
                                            searchTag = player.tag
                                            searchPlayer()
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: 300)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Tips:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TipRow(icon: "number", text: "Player tags start with #")
                    TipRow(icon: "star.fill", text: "Save favorite players for quick access")
                    TipRow(icon: "arrow.clockwise", text: "Pull down to refresh player data")
                }
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func searchPlayer() {
        let tag = searchTag.hasPrefix("#") ? searchTag : "#\(searchTag)"
        Task {
            await playerVM.fetchPlayer(tag: tag)
        }
    }
}

struct SavedPlayerRow: View {
    let player: SavedPlayer
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(player.tag)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.orange)
                    Text("\(player.trophies)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}
