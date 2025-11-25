//
//  BattleViewModel.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 11/24/25.
//


import Foundation
import SwiftUI

@MainActor
class BattleViewModel: ObservableObject {
    @Published var battles: [BattleDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let api = ClashAPI.shared
    
    func fetchBattles(for tag: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedBattles = try await api.fetchBattles(tag: tag)
            self.battles = fetchedBattles
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error fetching battles: \(error)")
        }
        
        isLoading = false
    }
    
    func refreshBattles(for tag: String) async {
        await fetchBattles(for: tag)
    }
    
    var winCount: Int {
        battles.filter { $0.isVictory }.count
    }
    
    var lossCount: Int {
        battles.filter { !$0.isVictory && !$0.isDraw }.count
    }
    
    var drawCount: Int {
        battles.filter { $0.isDraw }.count
    }
    
    var winRate: Double {
        let total = battles.count
        guard total > 0 else { return 0 }
        return Double(winCount) / Double(total) * 100
    }
    
    var averageCrowns: Double {
        guard !battles.isEmpty else { return 0 }
        let totalCrowns = battles.compactMap { $0.team.first?.crowns }.reduce(0, +)
        return Double(totalCrowns) / Double(battles.count)
    }
    
    func clearError() {
        errorMessage = nil
    }
}
