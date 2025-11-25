//
//  LeaderboardViewModel.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 11/24/25.

import Foundation
import SwiftUI

@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var topPlayers: [TopPlayerDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedLocation: String = "global"
    @Published var locations: [ClashAPI.Location] = []
    
    func fetchTopPlayers(location: String = "global", limit: Int = 50) async {
        isLoading = true
        errorMessage = nil
        selectedLocation = location
        
        do {
            let url = URL(string: "https://randomuser.me/api/?results=\(limit)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            struct RandomUserResponse: Decodable {
                let results: [User]
                struct User: Decodable {
                    let name: Name
                    let login: Login
                    let nat: String
                    struct Name: Decodable {
                        let first: String
                        let last: String
                    }
                    struct Login: Decodable {
                        let uuid: String
                    }
                }
            }
            
            let response = try JSONDecoder().decode(RandomUserResponse.self, from: data)
            
            self.topPlayers = response.results.enumerated().map { index, user in
                let rank = index + 1
                let trophies = 15000 - (index * 50)
                
                return TopPlayerDTO(
                    tag: "#\(user.login.uuid.prefix(8).uppercased())",
                    name: "\(user.name.first) \(user.name.last)",
                    rank: rank,
                    previousRank: rank > 1 ? rank - 1 : nil,
                    expLevel: Int.random(in: 40...60),
                    trophies: trophies,
                    clan: PlayerDTO.ClanSummary(
                        name: "Clan \(rank)",
                        tag: "#\(UUID().uuidString.prefix(8))",
                        badgeId: nil
                    ),
                    arena: nil
                )
            }
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchLocations() async {
        self.locations = [
            ClashAPI.Location(id: 32000249, name: "United States", isCountry: true, countryCode: "US"),
            ClashAPI.Location(id: 32000007, name: "Brazil", isCountry: true, countryCode: "BR"),
            ClashAPI.Location(id: 32000094, name: "India", isCountry: true, countryCode: "IN")
        ]
    }
    
    func refreshLeaderboard() async {
        await fetchTopPlayers(location: selectedLocation)
    }
    
    func clearError() {
        errorMessage = nil
    }
}
