//
//  ClashAPI.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//

import Foundation

actor ClashAPI {
    static let shared = ClashAPI()
    private let base = URL(string: "https://api.clashroyale.com/v1")!
    private let token: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiIsImtpZCI6IjI4YTMxOGY3LTAwMDAtYTFlYi03ZmExLTJjNzQzM2M2Y2NhNSJ9.eyJpc3MiOiJzdXBlcmNlbGwiLCJhdWQiOiJzdXBlcmNlbGw6Z2FtZWFwaSIsImp0aSI6ImJmZjQyNjc4LWFiZjktNDRjNS05N2UxLTcyN2RkNDNlZWE0NyIsImlhdCI6MTc2MTg4OTMyNCwic3ViIjoiZGV2ZWxvcGVyLzhlMzhkNGMwLWE4ZDktYzFjYy05ZmRmLTc1NDg1Mjc3OTBhOCIsInNjb3BlcyI6WyJyb3lhbGUiXSwibGltaXRzIjpbeyJ0aWVyIjoiZGV2ZWxvcGVyL3NpbHZlciIsInR5cGUiOiJ0aHJvdHRsaW5nIn0seyJjaWRycyI6WyIxMjkuMjE5LjguMTAwIl0sInR5cGUiOiJjbGllbnQifV19.88_sUU3_wJfUydVOHAYRulQhwR3okF04FlehIJX4ymd_HGL4f7cZDc3UwqaNvj3KLTDKGdqQVFGGdFESMeCNgQ"
    func request(_ path: String, query: [URLQueryItem] = []) throws -> URLRequest {
        var comps = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        comps.queryItems = query.isEmpty ? nil : query
        var req = URLRequest(url: comps.url!)
        req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return req
    }
    func player(tag: String) async throws -> PlayerDTO {
        let encoded = tag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tag
        let req = try request("players/\(encoded)")
        let (data, _) = try await URLSession.shared.data(for: req)
        
        if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
            throw NSError(domain: "APIError", code: 1, userInfo: [NSLocalizedDescriptionKey: apiError.message])
        }
        
        return try JSONDecoder().decode(PlayerDTO.self, from: data)
    }

    private struct APIError: Decodable {
        let reason: String
        let message: String
    }
    func battles(tag: String) async throws -> [BattleDTO] {
        let encoded = tag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tag
        let req = try request("players/\(encoded)/battlelog")
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode([BattleDTO].self, from: data)
    }
    func topPlayers(locationId: String = "global", limit: Int = 50) async throws -> [TopPlayerDTO] {
        let path = locationId == "global" ? "top/players" : "locations/\(locationId)/rankings/players"
        let req = try request(path, query: [URLQueryItem(name: "limit", value: String(limit))])
        let (data, _) = try await URLSession.shared.data(for: req)
        struct Wrap: Decodable { let items: [Item]
            struct Item: Decodable { let tag: String; let name: String; let rank: Int; let clan: PlayerDTO.ClanSummary? }
        }
        let wrap = try JSONDecoder().decode(Wrap.self, from: data)
        return wrap.items.map { TopPlayerDTO(tag: $0.tag, name: $0.name, rank: $0.rank, clan: $0.clan) }
    }
}
