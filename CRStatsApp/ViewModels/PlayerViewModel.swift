//
//  PlayerViewModel.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//

import Foundation

@MainActor
final class PlayerViewModel: ObservableObject {
    @Published var queryTag: String = ""
    @Published var player: PlayerDTO?
    @Published var battles: [BattleDTO] = []
    @Published var isLoading = false
    @Published var error: String?
    func loadAll() async {
        guard !queryTag.isEmpty else { return }
        isLoading = true
        error = nil
        do {
            let p = try await ClashAPI.shared.player(tag: queryTag)
            let b = try await ClashAPI.shared.battles(tag: queryTag)
            player = p
            battles = b
        } catch {
            self.error = String(describing: error)
        }
        isLoading = false
    }
}
