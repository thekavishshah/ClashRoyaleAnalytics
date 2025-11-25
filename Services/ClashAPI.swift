//
//  ClashAPI.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//

import Foundation

actor ClashAPI {
    static let shared = ClashAPI()
    
    private let baseURL = URL(string: "https://api.clashroyale.com/v1")!
    private let apiToken: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiIsImtpZCI6IjI4YTMxOGY3LTAwMDAtYTFlYi03ZmExLTJjNzQzM2M2Y2NhNSJ9.eyJpc3MiOiJzdXBlcmNlbGwiLCJhdWQiOiJzdXBlcmNlbGw6Z2FtZWFwaSIsImp0aSI6ImQxMTc1NTFiLTRjMzAtNDU1Mi1hZGFlLWJiNWU1ZjFmYmJlNSIsImlhdCI6MTc2MTkwMTMxNywic3ViIjoiZGV2ZWxvcGVyLzhlMzhkNGMwLWE4ZDktYzFjYy05ZmRmLTc1NDg1Mjc3OTBhOCIsInNjb3BlcyI6WyJyb3lhbGUiXSwibGltaXRzIjpbeyJ0aWVyIjoiZGV2ZWxvcGVyL3NpbHZlciIsInR5cGUiOiJ0aHJvdHRsaW5nIn0seyJjaWRycyI6WyI2OC4xNS4xNTkuOTAiXSwidHlwZSI6ImNsaWVudCJ9XX0.Uf64s16vQtn180X2kfXZEgtZBuDiZ4pQ2Xmm8lTsHBg-WL3LuB3ZUP31yzVx2X6ahXVl4ZdlWn0z6C7rZuRotQ"
    
    private init() {}
    
    private func createRequest(path: String, queryItems: [URLQueryItem] = []) throws -> URLRequest {
        let fullURLString = baseURL.absoluteString + "/" + path
        var components = URLComponents(string: fullURLString)!
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    private func executeRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(apiError.message)
            }
            throw APIError.statusCode(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response data: \(jsonString)")
            }
            throw APIError.decodingFailed(error)
        }
    }
    
    func fetchPlayer(tag: String) async throws -> PlayerDTO {
        let encodedTag = encodeTag(tag)
        let request = try createRequest(path: "players/\(encodedTag)")
        return try await executeRequest(request)
    }
    
    func fetchBattles(tag: String) async throws -> [BattleDTO] {
        let encodedTag = encodeTag(tag)
        let request = try createRequest(path: "players/\(encodedTag)/battlelog")
        return try await executeRequest(request)
    }
    
    func fetchTopPlayers(locationId: String = "global", limit: Int = 50) async throws -> [TopPlayerDTO] {
        let baseURL = "https://api.clashofclans.com/v1"
        var path: String
        if locationId == "global" {
            path = "rankings/global/players"
        } else {
            path = "locations/\(locationId)/rankings/players"
        }
        
        let fullURLString = baseURL + "/" + path
        var components = URLComponents(string: fullURLString)!
        components.queryItems = [URLQueryItem(name: "limit", value: String(min(limit, 200)))]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(apiError.message)
            }
            throw APIError.statusCode(httpResponse.statusCode)
        }
        
        struct CoCPlayerItem: Decodable {
            let tag: String
            let name: String
            let rank: Int
            let previousRank: Int?
            let expLevel: Int?
            let trophies: Int?
            let clan: ClanInfo?
            
            struct ClanInfo: Decodable {
                let name: String?
                let tag: String?
            }
        }
        
        struct CoCResponse: Decodable {
            let items: [CoCPlayerItem]
        }
        
        let decoder = JSONDecoder()
        let cocResult = try decoder.decode(CoCResponse.self, from: data)
        
        let topPlayers = cocResult.items.map { cocPlayer in
            TopPlayerDTO(
                tag: cocPlayer.tag,
                name: cocPlayer.name,
                rank: cocPlayer.rank,
                previousRank: cocPlayer.previousRank,
                expLevel: cocPlayer.expLevel,
                trophies: cocPlayer.trophies,
                clan: cocPlayer.clan != nil ? PlayerDTO.ClanSummary(
                    name: cocPlayer.clan?.name,
                    tag: cocPlayer.clan?.tag,
                    badgeId: nil
                ) : nil,
                arena: nil
            )
        }
        
        return topPlayers
    }

    func fetchLocations() async throws -> [Location] {
        let baseURL = "https://api.clashofclans.com/v1"
        let fullURLString = baseURL + "/locations"
        
        guard let url = URL(string: fullURLString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            throw APIError.statusCode(httpResponse.statusCode)
        }
        
        struct LocationsResponse: Decodable {
            let items: [Location]
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(LocationsResponse.self, from: data)
        return result.items
    }
    
    private func encodeTag(_ tag: String) -> String {
        var charset = CharacterSet.urlPathAllowed
        charset.remove(charactersIn: "#")
        return tag.addingPercentEncoding(withAllowedCharacters: charset) ?? tag
    }
    
    struct Location: Decodable, Identifiable {
        let id: Int
        let name: String
        let isCountry: Bool
        let countryCode: String?
        
        var displayName: String {
            if let flag = countryCode?.unicodeScalarFlag {
                return "\(flag) \(name)"
            }
            return name
        }
    }
    
    private struct APIErrorResponse: Decodable {
        let reason: String
        let message: String
    }
    
    enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case statusCode(Int)
        case serverError(String)
        case decodingFailed(Error)
        case networkError(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .statusCode(let code):
                return "Server returned status code: \(code)"
            case .serverError(let message):
                return message
            case .decodingFailed(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }
}

extension String {
    var unicodeScalarFlag: String? {
        guard self.count == 2 else { return nil }
        let base: UInt32 = 127397
        var flag = ""
        for scalar in self.uppercased().unicodeScalars {
            if let unicodeScalar = UnicodeScalar(base + scalar.value) {
                flag.append(String(unicodeScalar))
            }
        }
        return flag
    }
}
