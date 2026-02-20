//
//  GameRepository.swift
//  Anime
//
//  Created by elene malakmadze on 20.02.26.
//

import CoreData
import Foundation

final class GameRepository {
    static let shared = GameRepository()
    private let coreData = CoreDataManager.shared

    private init() {}

    func saveScore(score: Int16, streak: Int16, for user: User) -> GameScore {
        let gameScore = GameScore(context: coreData.context)
        gameScore.score = score
        gameScore.bestStreak = streak
        gameScore.user = user

        coreData.saveContext()
        return gameScore
    }

    func fetchAllScores(for user: User) -> [GameScore] {
        let request: NSFetchRequest<GameScore> = GameScore.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        return coreData.fetch(request)
    }

    func fetchHighScore(for user: User) -> Int32 {
        let scores = fetchAllScores(for: user)
        return scores.map { Int32($0.score) }.max() ?? 0
    }

    func fetchBestStreak(for user: User) -> Int32 {
        let scores = fetchAllScores(for: user)
        return scores.map { Int32($0.bestStreak) }.max() ?? 0
    }

    func fetchRecentScores(for user: User, limit: Int = 10) -> [GameScore] {
        let request: NSFetchRequest<GameScore> = GameScore.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.fetchLimit = limit
        return coreData.fetch(request)
    }

    func fetchAverageScore(for user: User) -> Double {
        let scores = fetchAllScores(for: user)
        guard !scores.isEmpty else { return 0.0 }
        let total = scores.reduce(0) { $0 + Int($1.score) }
        return Double(total) / Double(scores.count)
    }
}
