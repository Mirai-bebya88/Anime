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
    let trailer: AnimeTrailer?
    let year: Int?
    let synopsis: String?
    let broadcast: AnimeBroadcast?


    var id: Int { malId }

    var displayTitle: String {
        titleEnglish ?? title
    }

    var imageURL: String? {
        images?.jpg?.imageUrl ?? images?.jpg?.largeImageUrl
    }
    
    var largeImageURL: String? {
        images?.jpg?.largeImageUrl ?? images?.jpg?.imageUrl
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

struct AnimeTrailer: Codable {
    let youtubeId: String?
    let url: String?
    let embedUrl: String?
}

struct AnimeBroadcast: Codable {
    let day: String?
    let time: String?
    let timezone: String?
    let string: String?
}
