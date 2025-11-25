//
//  Player.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//


import Foundation

struct PlayerDTO: Decodable, Identifiable {
    var id: String { tag }
    let tag: String
    let name: String
    let expLevel: Int?
    let trophies: Int?
    let bestTrophies: Int?
    let wins: Int?
    let losses: Int?
    let battleCount: Int?
    let threeCrownWins: Int?
    let challengeCardsWon: Int?
    let challengeMaxWins: Int?
    let tournamentCardsWon: Int?
    let tournamentBattleCount: Int?
    let role: String?
    let donations: Int?
    let donationsReceived: Int?
    let totalDonations: Int?
    let warDayWins: Int?
    let clanCardsCollected: Int?
    let clan: ClanSummary?
    let arena: Arena?
    let leagueStatistics: LeagueStatistics?
    let cards: [Card]?
    let currentDeck: [Card]?
    let currentFavouriteCard: Card?
    
    struct ClanSummary: Decodable {
        let name: String?
        let tag: String?
        let badgeId: Int?
    }
    
    struct Arena: Decodable {
        let id: Int?
        let name: String?
    }
    
    struct LeagueStatistics: Decodable {
        let currentSeason: Season?
        let previousSeason: Season?
        let bestSeason: Season?
        
        struct Season: Decodable {
            let trophies: Int?
            let bestTrophies: Int?
        }
    }
    
    struct Card: Decodable, Identifiable {
        var id: Int { iconUrls?.medium?.hashValue ?? name.hashValue }
        let name: String
        let level: Int?
        let maxLevel: Int?
        let rarity: String?
        let count: Int?
        let iconUrls: IconUrls?
        
        struct IconUrls: Decodable {
            let medium: String?
        }
    }
    
    var winRate: Double {
        guard let w = wins, let l = losses, (w + l) > 0 else { return 0.0 }
        return Double(w) / Double(w + l) * 100
    }
    
    var totalBattles: Int {
        (wins ?? 0) + (losses ?? 0)
    }
}
