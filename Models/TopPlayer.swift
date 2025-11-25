//
//  TopPlayer.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/30/25.
//
import Foundation

struct TopPlayerDTO: Decodable, Identifiable {
    var id: String { tag }
    let tag: String
    let name: String
    let rank: Int
    let previousRank: Int?
    let expLevel: Int?
    let trophies: Int?
    let clan: PlayerDTO.ClanSummary?
    let arena: Arena?
    
    struct Arena: Decodable {
        let id: Int?
        let name: String?
    }
    
    var rankChangeDisplay: String {
        guard let prev = previousRank else { return "NEW" }
        let change = prev - rank
        if change > 0 {
            return "↑\(change)"
        } else if change < 0 {
            return "↓\(abs(change))"
        } else {
            return "−"
        }
    }
}
