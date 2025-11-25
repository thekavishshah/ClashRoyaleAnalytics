//
//  WorldMapView.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/29/25.
//

import SwiftUI
import MapKit

struct WorldMapView: View {
    @ObservedObject var leaderboardVM: LeaderboardViewModel
    @ObservedObject var locationManager: LocationManager
    
    @State private var selectedPlayer: TopPlayerDTO?
    @State private var showPlayerDetail = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                // User Location
                if let userLocation = locationManager.userLocation {
                    Annotation("You", coordinate: userLocation) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 20)
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                
                ForEach(playerLocations) { playerLocation in
                    Annotation(playerLocation.player.name,
                             coordinate: playerLocation.coordinate) {
                        PlayerMapMarker(player: playerLocation.player)
                            .onTapGesture {
                                selectedPlayer = playerLocation.player
                                showPlayerDetail = true
                            }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            Task {
                                await leaderboardVM.refreshLeaderboard()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Button(action: centerOnUserLocation) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Button(action: showAllPlayers) {
                            Image(systemName: "map")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                if !leaderboardVM.topPlayers.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🌍 Top Players Worldwide")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Showing \(playerLocations.count) players on map")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if leaderboardVM.selectedLocation != "global" {
                            Text("Region: \(leaderboardVM.selectedLocation)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding()
                }
            }
        }
        .navigationTitle("World Map")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPlayerDetail) {
            if let player = selectedPlayer {
                PlayerDetailSheet(player: player)
            }
        }
        .task {
            locationManager.requestLocation()
            if leaderboardVM.topPlayers.isEmpty {
                await leaderboardVM.fetchTopPlayers(limit: 200)
            }
        }
        .onAppear {
            showAllPlayers()
        }
    }
    
    
    private var playerLocations: [PlayerLocation] {
        leaderboardVM.topPlayers.compactMap { player in
            guard let clan = player.clan,
                  let countryCode = clan.tag?.prefix(2).uppercased(),
                  let coordinate = locationManager.coordinatesForCountry(code: String(countryCode)) else {
                return getDefaultLocation(for: player)
            }
            
            let latOffset = Double.random(in: -2...2)
            let lonOffset = Double.random(in: -2...2)
            let adjustedCoordinate = CLLocationCoordinate2D(
                latitude: coordinate.latitude + latOffset,
                longitude: coordinate.longitude + lonOffset
            )
            
            return PlayerLocation(player: player, coordinate: adjustedCoordinate)
        }
    }
    
    
    private func getDefaultLocation(for player: TopPlayerDTO) -> PlayerLocation? {
        let defaultLocations: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),   // London
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),  // New York
            CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),  // Tokyo
            CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), // Sydney
            CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)   // Mexico City
        ]
        
        let randomLocation = defaultLocations.randomElement()!
        return PlayerLocation(player: player, coordinate: randomLocation)
    }
    
    private func centerOnUserLocation() {
        if let userLocation = locationManager.userLocation {
            cameraPosition = .region(MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
            ))
        }
    }
    
    private func showAllPlayers() {
        if !playerLocations.isEmpty {
            let coordinates = playerLocations.map { $0.coordinate }
            let minLat = coordinates.map { $0.latitude }.min() ?? 0
            let maxLat = coordinates.map { $0.latitude }.max() ?? 0
            let minLon = coordinates.map { $0.longitude }.min() ?? 0
            let maxLon = coordinates.map { $0.longitude }.max() ?? 0
            
            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )
            
            let span = MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) * 1.5,
                longitudeDelta: (maxLon - minLon) * 1.5
            )
            
            cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
}

struct PlayerLocation: Identifiable {
    let id = UUID()
    let player: TopPlayerDTO
    let coordinate: CLLocationCoordinate2D
}

struct PlayerMapMarker: View {
    let player: TopPlayerDTO
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 30, height: 30)
                
                Text("\(player.rank)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Triangle()
                .fill(rankColor)
                .frame(width: 10, height: 8)
                .offset(y: -1)
        }
        .shadow(radius: 3)
    }
    
    private var rankColor: Color {
        switch player.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        case 4...10: return .purple
        default: return .blue
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct PlayerDetailSheet: View {
    let player: TopPlayerDTO
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 100, height: 100)
                    
                    VStack(spacing: 4) {
                        Text("#\(player.rank)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("RANK")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.top)
                
                VStack(spacing: 12) {
                    Text(player.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(player.tag)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("\(player.trophies ?? 0)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Trophies")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    if let clan = player.clan, let clanName = clan.name {
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.cyan)
                                Text(clanName)
                                    .font(.headline)
                            }
                            
                            if let clanTag = clan.tag {
                                Text(clanTag)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Player Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var rankColor: Color {
        switch player.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
}
