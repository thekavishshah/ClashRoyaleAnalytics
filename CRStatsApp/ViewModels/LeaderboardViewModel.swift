//
//  LeaderboardViewModel.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//

import Foundation

@MainActor
final class LeaderboardViewModel: ObservableObject {
    @Published var top: [TopPlayerDTO] = []
    @Published var isLoading = false
    @Published var error: String?
    func load() async {
        isLoading = true
        error = nil
        do {
            top = try await ClashAPI.shared.topPlayers()
        } catch {
            self.error = String(describing: error)
        }
        isLoading = false
    }
}
