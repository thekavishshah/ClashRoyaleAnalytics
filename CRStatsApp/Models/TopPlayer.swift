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
    let clan: PlayerDTO.ClanSummary?
}
