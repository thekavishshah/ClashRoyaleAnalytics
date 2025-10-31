//
//  Battle.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/30/25.
//

import Foundation

struct BattleDTO: Decodable, Identifiable {
    var id: String { battleTime }
    let battleTime: String
    let team: [Participant]
    let opponent: [Participant]
    struct Participant: Decodable {
        let tag: String?
        let name: String?
        let crowns: Int?
    }
}
