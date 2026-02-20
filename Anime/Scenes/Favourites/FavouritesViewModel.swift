//
//  FavouritesViewModel.swift
//  Anime
//
//  Created by elene malakmadze on 17.02.26.
//

import Foundation

protocol FavouritesViewModelProtocol: AnyObject {
    var savedAnime: [SavedAnime] { get }

    var refreshUI: (() -> Void)? { get set }

    func loadSavedAnime()
    func removeAnime(at index: Int)
}

final class FavouritesViewModel: FavouritesViewModelProtocol {
    private let animeRepository = AnimeRepository.shared
    private let userRepository = UserRepository.shared

    private(set) var savedAnime: [SavedAnime] = []

    var refreshUI: (() -> Void)?

    func loadSavedAnime() {
        guard let user = userRepository.currentUser else {
            savedAnime = []
            refreshUI?()
            return
        }

        savedAnime = animeRepository.fetchAllSavedAnime(for: user).filter { $0.isFavorite == true }
        refreshUI?()
    }

    func removeAnime(at index: Int) {
        let anime = savedAnime[index]
        if anime.watchStatus != nil {
            animeRepository.toggleFavorite(anime)
        } else {
            animeRepository.removeSavedAnime(anime)
        }
        loadSavedAnime()
    }

}
