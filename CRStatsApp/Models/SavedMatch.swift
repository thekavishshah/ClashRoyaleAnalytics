//
//  SavedMatch.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//

import Foundation
import SwiftData

@Model
class SavedMatch {
    var playerTag: String
    var opponent: String
    var result: String
    var crowns: Int
    var playedAt: Date
    init(playerTag: String, opponent: String, result: String, crowns: Int, playedAt: Date) {
        self.playerTag = playerTag
        self.opponent = opponent
        self.result = result
        self.crowns = crowns
        self.playedAt = playedAt
    }
}
