//
//  SavedPlayer.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//
import Foundation
import SwiftData

@Model
class SavedPlayer {
    var tag: String
    var name: String
    var trophies: Int
    var savedAt: Date
    var lastUpdated: Date?
    
    init(tag: String, name: String, trophies: Int = 0, savedAt: Date = .now, lastUpdated: Date = .now) {
        self.tag = tag
        self.name = name
        self.trophies = trophies
        self.savedAt = savedAt
        self.lastUpdated = lastUpdated
    }
}
