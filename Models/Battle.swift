//
//  Battle.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/30/25.
//


import Foundation

struct BattleDTO: Decodable, Identifiable {
    var id: String { battleTime }
    let type: String?
    let battleTime: String
    let isLadderTournament: Bool?
    let arena: Arena?
    let gameMode: GameMode?
    let deckSelection: String?
    let team: [Participant]
    let opponent: [Participant]
    
    struct Arena: Decodable {
        let id: Int?
        let name: String?
    }
    
    struct GameMode: Decodable {
        let id: Int?
        let name: String?
    }
    
    struct Participant: Decodable {
        let tag: String?
        let name: String?
        let startingTrophies: Int?
        let trophyChange: Int?
        let crowns: Int?
        let kingTowerHitPoints: Int?
        let princessTowersHitPoints: [Int]?
        let cards: [Card]?
    }
    
    struct Card: Decodable, Identifiable {
        var id: String { name }
        let name: String
        let level: Int?
        let maxLevel: Int?
        let iconUrls: IconUrls?
        
        struct IconUrls: Decodable {
            let medium: String?
        }
    }
    
    var isVictory: Bool {
        guard let myCrowns = team.first?.crowns,
              let oppCrowns = opponent.first?.crowns else {
            return false
        }
        return myCrowns > oppCrowns
    }
    
    var isDraw: Bool {
        guard let myCrowns = team.first?.crowns,
              let oppCrowns = opponent.first?.crowns else {
            return false
        }
        return myCrowns == oppCrowns
    }
    
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: battleTime) else {
            return battleTime
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
    
    var battleTypeDisplay: String {
        type?.capitalized ?? "Battle"
    }
}
