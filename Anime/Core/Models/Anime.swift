//
//  Anime.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import Foundation

struct Anime: Codable, Identifiable, Hashable {
    let malId: Int
    let images: AnimeImages?
    let title: String
    let titleEnglish: String?
    let type: String?
    let episodes: Int?
    let score: Double?

    var id: Int { malId }

    var displayTitle: String {
        titleEnglish ?? title
    }

    var imageURL: String? {
        images?.jpg?.imageUrl ?? images?.jpg?.largeImageUrl
    }

    static func == (lhs: Anime, rhs: Anime) -> Bool {
        lhs.malId == rhs.malId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(malId)
    }
}

struct AnimeImages: Codable {
    let jpg: AnimeImageFormat?
}

struct AnimeImageFormat: Codable {
    let imageUrl: String?
    let largeImageUrl: String?
}
