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
    var savedAt: Date
    init(tag: String, name: String, savedAt: Date = .now) {
        self.tag = tag
        self.name = name
        self.savedAt = savedAt
    }
}
