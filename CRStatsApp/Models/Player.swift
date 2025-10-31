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
    let clan: ClanSummary?
    struct ClanSummary: Decodable {
        let name: String?
        let tag: String?
    }
}
