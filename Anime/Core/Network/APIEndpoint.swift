//
//  APIEndpoint.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import Foundation

enum APIEndpoint {
    case searchAnime(query: String, page: Int)
    case animeByGenre(genreId: Int, page: Int)

    private var baseURL: String {
        return "https://api.jikan.moe/v4"
    }

    var url: URL? {
        switch self {
        case .searchAnime(let query, let page):
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            return URL(string: "\(baseURL)/anime?q=\(encodedQuery)&page=\(page)")

        case .animeByGenre(let genreId, let page):
            return URL(string: "\(baseURL)/anime?genres=\(genreId)&page=\(page)")
        }
    }
}
