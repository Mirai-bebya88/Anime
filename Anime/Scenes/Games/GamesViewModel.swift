//
//  GamesViewModel.swift
//  Anime
//
//  Created by elene malakmadze on 20.02.26.
//

import Foundation

protocol GamesViewModelProtocol: AnyObject {
    var highScore: Int32 { get }
    var bestStreak: Int32 { get }

    var refreshUI: (() -> Void)? { get set }

    func loadStats()
}

final class GamesViewModel: GamesViewModelProtocol {
    private let gameRepository = GameRepository.shared
    private let userRepository = UserRepository.shared

    private(set) var highScore: Int32 = 0
    private(set) var bestStreak: Int32 = 0

    var refreshUI: (() -> Void)?

    func loadStats() {
        guard let user = userRepository.currentUser else {
            highScore = 0
            bestStreak = 0
            refreshUI?()
            return
        }

        highScore = gameRepository.fetchHighScore(for: user)
        bestStreak = gameRepository.fetchBestStreak(for: user)
        refreshUI?()
    }
}
