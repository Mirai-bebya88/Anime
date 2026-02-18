//
//  AnimeService.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import Foundation

final class AnimeService {
    static let shared = AnimeService()
    private let networkManager = NetworkManager.shared

    private init() {}

    func searchAnime(query: String, page: Int = 1) async throws -> AnimeListResponse {
        return try await networkManager.fetch(.searchAnime(query: query, page: page))
    }

    func fetchAnimeByGenre(genreId: Int, page: Int = 1) async throws -> AnimeListResponse {
        return try await networkManager.fetch(.animeByGenre(genreId: genreId, page: page))
    }
    
    func fetchAnimeDetails(id: Int) async throws -> AnimeSingleResponse {
        return try await networkManager.fetch(.animeDetails(id: id))
    }
    
    func fetchSeasonalAnime(page: Int = 1) async throws -> AnimeListResponse {
        return try await networkManager.fetch(.seasonNow(page: page))
    }
}
