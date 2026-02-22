//
//  GamesDetailViewModel.swift
//  Anime
//
//  Created by elene malakmadze on 20.02.26.
//

import Foundation

protocol GamesDetailViewModelProtocol: AnyObject {
    var topAnime: Anime? { get }
    var bottomAnime: Anime? { get }
    var currentScore: Int { get }
    var currentStreak: Int { get }
    var questionsAnswered: Int { get }
    var totalQuestions: Int { get }
    var isGameOver: Bool { get }

    var refreshUI: (() -> Void)? { get set }
    var onCorrectAnswer: (() -> Void)? { get set }
    var onWrongAnswer: (() -> Void)? { get set }
    var onGameOver: (() -> Void)? { get set }
    var showError: ((String) -> Void)? { get set }
    var showLoading: ((Bool) -> Void)? { get set }

    func startNewGame() async
    func pickNewPair()
    func selectAnime(_ selection: GamesDetailViewModel.Selection)
}

final class GamesDetailViewModel: GamesDetailViewModelProtocol {
    private let animeService = AnimeService.shared
    private let gameRepository = GameRepository.shared
    private let userRepository = UserRepository.shared

    private var animePool: [Anime] = []
    private(set) var topAnime: Anime?
    private(set) var bottomAnime: Anime?

    private(set) var currentScore: Int = 0
    private(set) var currentStreak: Int = 0
    private var bestStreak: Int = 0
    private(set) var questionsAnswered: Int = 0
    let totalQuestions: Int = 10

    private(set) var isGameOver = false

    var refreshUI: (() -> Void)?
    var onCorrectAnswer: (() -> Void)?
    var onWrongAnswer: (() -> Void)?
    var onGameOver: (() -> Void)?
    var showError: ((String) -> Void)?
    var showLoading: ((Bool) -> Void)?

    func startNewGame() async {
        isGameOver = false
        currentScore = 0
        currentStreak = 0
        bestStreak = 0
        questionsAnswered = 0

        await loadAnimePool()
        pickNewPair()
    }

    private func loadAnimePool() async {
        showLoading?(true)

        do {
            let page1 = Int.random(in: 1...10)
            let page2 = page1 == 10 ? 1 : page1 + 1

            let response = try await animeService.fetchTopAnime(page: page1, filter: nil)
            animePool = response.data.filter { ($0.score ?? 0) > 0 }

            let response2 = try await animeService.fetchTopAnime(page: page2, filter: nil)
            animePool.append(contentsOf: response2.data.filter { ($0.score ?? 0) > 0 })

            animePool.shuffle()
        } catch {
            showError?("Failed to load anime. Please try again.")
        }

        showLoading?(false)
    }

    func pickNewPair() {
        guard animePool.count >= 2 else {
            showError?("Not enough anime to play.")
            return
        }

        var shuffled = animePool.shuffled()
        topAnime = shuffled.removeFirst()
        bottomAnime = shuffled.first { $0.malId != topAnime?.malId }

        refreshUI?()
    }

    func selectAnime(_ selection: Selection) {
        guard let top = topAnime, let bottom = bottomAnime,
              let topScore = top.score, let bottomScore = bottom.score else {
            return
        }

        let isCorrect: Bool
        switch selection {
        case .top:
            isCorrect = topScore >= bottomScore
        case .bottom:
            isCorrect = bottomScore >= topScore
        }

        questionsAnswered += 1

        if isCorrect {
            currentScore += 1
            currentStreak += 1
            bestStreak = max(bestStreak, currentStreak)
            onCorrectAnswer?()
        } else {
            currentStreak = 0
            onWrongAnswer?()
        }

        if questionsAnswered >= totalQuestions {
            isGameOver = true
            saveScore()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.onGameOver?()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                self?.pickNewPair()
            }
        }
    }

    private func saveScore() {
        guard let user = userRepository.currentUser else { return }
        gameRepository.saveScore(score: Int16(currentScore), streak: Int16(bestStreak), for: user)
    }

    enum Selection {
        case top
        case bottom
    }
}
