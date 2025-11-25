//
//  PlayerViewModel.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//

import Foundation
import SwiftUI

@MainActor
class PlayerViewModel: ObservableObject {
    @Published var currentPlayer: PlayerDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var recentlyViewedTags: [String] = []
    
    private let api = ClashAPI.shared
    private let maxRecentTags = 10
    
    func fetchPlayer(tag: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let player = try await api.fetchPlayer(tag: tag)
            self.currentPlayer = player
            addToRecentlyViewed(tag: tag)
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error fetching player: \(error)")
        }
        
        isLoading = false
    }
    
    func refreshCurrentPlayer() async {
        guard let tag = currentPlayer?.tag else { return }
        await fetchPlayer(tag: tag)
    }
    
    private func addToRecentlyViewed(tag: String) {
        if let index = recentlyViewedTags.firstIndex(of: tag) {
            recentlyViewedTags.remove(at: index)
        }
        recentlyViewedTags.insert(tag, at: 0)
        if recentlyViewedTags.count > maxRecentTags {
            recentlyViewedTags.removeLast()
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
