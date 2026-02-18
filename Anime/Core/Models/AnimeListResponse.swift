//
//  AnimeListResponse.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import Foundation

struct AnimeListResponse: Codable {
    let pagination: Pagination?
    let data: [Anime]
}

struct AnimeSingleResponse: Codable {
    let data: Anime
}

struct Pagination: Codable {
    let lastVisiblePage: Int?
    let hasNextPage: Bool?
    let currentPage: Int?
    let items: PaginationItems?
}

struct PaginationItems: Codable {
    let count: Int?
    let total: Int?
    let perPage: Int?
}
