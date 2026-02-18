//
//  AnimeRepository.swift
//  Anime
//
//  Created by elene malakmadze on 12.02.26.
//

import CoreData
import Foundation

enum WatchStatus: String, CaseIterable {
    case watching = "watching"
    case plan = "plan"

    var displayName: String {
        switch self {
        case .watching: return "Watching"
        case .plan: return "Plan to Watch"
        }
    }
}

final class AnimeRepository {
    static let shared = AnimeRepository()
    private let coreData = CoreDataManager.shared

    private init() {}

    func saveAnime(_ anime: Anime, for user: User, status: WatchStatus = .plan) -> SavedAnime? {
        if let existing = fetchSavedAnime(malId: anime.malId, for: user) {
            return existing
        }

        let savedAnime = SavedAnime(context: coreData.context)
        savedAnime.malId = Int64(anime.malId)
        savedAnime.title = anime.displayTitle
        savedAnime.imageURL = anime.imageURL
        savedAnime.synopsis = anime.synopsis
        savedAnime.score = anime.score ?? 0.0
        savedAnime.episodes = Int16(anime.episodes ?? 0)
        savedAnime.year = Int16(anime.year ?? 0)
        savedAnime.watchStatus = status.rawValue
        savedAnime.isFavorite = false
        savedAnime.dateAdded = Date()
        savedAnime.user = user

        coreData.saveContext()
        return savedAnime
    }

    func saveAnimeAsFavorite(_ anime: Anime, for user: User) -> SavedAnime? {
        if let existing = fetchSavedAnime(malId: anime.malId, for: user) {
            existing.isFavorite = true
            coreData.saveContext()
            return existing
        }

        let savedAnime = SavedAnime(context: coreData.context)
        savedAnime.malId = Int64(anime.malId)
        savedAnime.title = anime.displayTitle
        savedAnime.imageURL = anime.imageURL
        savedAnime.synopsis = anime.synopsis
        savedAnime.score = anime.score ?? 0.0
        savedAnime.episodes = Int16(anime.episodes ?? 0)
        savedAnime.year = Int16(anime.year ?? 0)
        savedAnime.watchStatus = nil
        savedAnime.isFavorite = true
        savedAnime.dateAdded = Date()
        savedAnime.user = user

        coreData.saveContext()
        return savedAnime
    }

    func updateWatchStatus(_ savedAnime: SavedAnime, status: WatchStatus) {
        savedAnime.watchStatus = status.rawValue
        coreData.saveContext()
    }

    func toggleFavorite(_ savedAnime: SavedAnime) {
        savedAnime.isFavorite = !savedAnime.isFavorite
        coreData.saveContext()
    }

    func removeSavedAnime(_ savedAnime: SavedAnime) {
        coreData.delete(savedAnime)
    }

    func fetchSavedAnime(malId: Int, for user: User) -> SavedAnime? {
        let request: NSFetchRequest<SavedAnime> = SavedAnime.fetchRequest()
        request.predicate = NSPredicate(format: "malId == %lld AND user == %@", Int64(malId), user)
        request.fetchLimit = 1
        return coreData.fetch(request).first
    }

    func fetchAllSavedAnime(for user: User) -> [SavedAnime] {
        let request: NSFetchRequest<SavedAnime> = SavedAnime.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        return coreData.fetch(request)
    }
}
