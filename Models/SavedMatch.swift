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
    var battleTime: String
    var playerTag: String
    var opponentName: String
    var playerCrowns: Int
    var opponentCrowns: Int
    var isVictory: Bool
    var battleType: String
    var trophyChange: Int?
    var savedAt: Date
    
    init(battleTime: String,
         playerTag: String,
         opponentName: String,
         playerCrowns: Int,
         opponentCrowns: Int,
         isVictory: Bool,
         battleType: String,
         trophyChange: Int? = nil,
         savedAt: Date = .now) {
        self.battleTime = battleTime
        self.playerTag = playerTag
        self.opponentName = opponentName
        self.playerCrowns = playerCrowns
        self.opponentCrowns = opponentCrowns
        self.isVictory = isVictory
        self.battleType = battleType
        self.trophyChange = trophyChange
        self.savedAt = savedAt
    }
    
    var resultDisplay: String {
        if playerCrowns > opponentCrowns {
            return "Victory"
        } else if playerCrowns < opponentCrowns {
            return "Defeat"
        } else {
            return "Draw"
        }
    }
    
    var scoreDisplay: String {
        "\(playerCrowns) - \(opponentCrowns)"
    }
}
