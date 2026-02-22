//
//  AnimeDetailViewModel.swift
//  Anime
//
//  Created by elene malakmadze on 11.02.26.
//

import Foundation

protocol AnimeDetailViewModelProtocol: AnyObject {
    var anime: Anime { get }
    var currentAnime: Anime { get }
    var isSaved: Bool { get }
    var isFavorite: Bool { get }
    var currentWatchStatus: WatchStatus? { get }
    var refreshUI: (() -> Void)? { get set }
    var showError: ((String) -> Void)? { get set }
    var showLoading: ((Bool) -> Void)? { get set }

    func loadDetails() async
    func saveToList(status: WatchStatus)
    func removeFromList()
    func addToFavorites()
    func removeFromFavorites()
}

final class AnimeDetailViewModel: AnimeDetailViewModelProtocol {
    private let animeService = AnimeService.shared
    private let animeRepository = AnimeRepository.shared
    private let userRepository = UserRepository.shared

    let anime: Anime
    private var detailedAnime: Anime?
    private var savedAnime: SavedAnime?

    var refreshUI: (() -> Void)?
    var showError: ((String) -> Void)?
    var showLoading: ((Bool) -> Void)?

    init(anime: Anime) {
        self.anime = anime
        loadSavedStatus()
    }

    var currentAnime: Anime {
        detailedAnime ?? anime
    }

    var isSaved: Bool {
        if let _ = savedAnime { return true }
        return false
    }

    var isFavorite: Bool {
        savedAnime?.isFavorite == true
    }

    var currentWatchStatus: WatchStatus? {
        guard let statusString = savedAnime?.watchStatus else { return nil }
        return WatchStatus(rawValue: statusString)
    }

    func loadDetails() async {
        showLoading?(true)

        do {
            let response = try await animeService.fetchAnimeDetails(id: anime.malId)
            detailedAnime = response.data
            refreshUI?()
        } catch {
            showError?(mapError(error))
        }

        showLoading?(false)
    }

    private func loadSavedStatus() {
        guard let user = userRepository.currentUser else { return }
        savedAnime = animeRepository.fetchSavedAnime(malId: anime.malId, for: user)
    }

    func saveToList(status: WatchStatus) {
        guard let user = userRepository.currentUser else {
            showError?("Please sign in to save anime")
            return
        }

        if let existing = savedAnime {
            animeRepository.updateWatchStatus(existing, status: status)
        } else {
            savedAnime = animeRepository.saveAnime(currentAnime, for: user, status: status)
        }
        refreshUI?()
    }

    func removeFromList() {
        guard let saved = savedAnime else { return }
        if saved.isFavorite {
            animeRepository.clearWatchStatus(saved)
        } else {
            animeRepository.removeSavedAnime(saved)
            savedAnime = nil
        }
        refreshUI?()
    }

    func addToFavorites() {
        guard let user = userRepository.currentUser else {
            showError?("Please sign in to add favorites")
            return
        }

        if let existing = savedAnime {
            animeRepository.toggleFavorite(existing)
        } else {
            savedAnime = animeRepository.saveAnimeAsFavorite(currentAnime, for: user)
        }
        refreshUI?()
    }

    func removeFromFavorites() {
        guard let saved = savedAnime else { return }
        if let _ = saved.watchStatus {
            animeRepository.toggleFavorite(saved)
        } else {
            animeRepository.removeSavedAnime(saved)
            savedAnime = nil
        }
        refreshUI?()
    }

    private func mapError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .rateLimited:
                return "Too many requests. Please wait a moment."
            default:
                return "Failed to load details."
            }
        }
        return "An error occurred."
    }
}
