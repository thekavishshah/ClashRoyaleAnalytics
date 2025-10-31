import Foundation
import Combine
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var playerTag = ""
    @Published var player: PlayerDTO?
    @Published var errorMessage: String?
    
    func fetchPlayer() {
        let trimmed = playerTag.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            do {
                let request = try await ClashAPI.shared.request("/players/\(trimmed)")
                let (data, _) = try await URLSession.shared.data(for: request)
                let decoded = try JSONDecoder().decode(PlayerDTO.self, from: data)
                self.player = decoded
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
                self.player = nil
            }
        }
    }
}

