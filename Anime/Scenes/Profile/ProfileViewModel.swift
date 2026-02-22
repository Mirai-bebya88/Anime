//
//  ProfileViewModel.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import Foundation
import UIKit

final class ProfileViewModel {
    private let userRepository = UserRepository.shared
    private let animeRepository = AnimeRepository.shared
    private let gameRepository = GameRepository.shared

    var user: User?
    var totalAnime: Int = 0
    var watchingCount: Int = 0
    var planToWatchCount: Int = 0
    var favouriteCount: Int = 0
    var averageGameScore: Double = 0.0
    var highestGameScore: Int32 = 0

    var onDataUpdated: (() -> Void)?
    
    var memberSinceString: String {
        guard let date = user?.memberSince else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var fullName: String {
        guard let user = user else { return "Guest" }
        return "\(user.username ?? "")"
    }

    func loadProfile() {
        user = userRepository.currentUser

        guard let user = user else {
            onDataUpdated?()
            return
        }

        let savedAnime = animeRepository.fetchAllSavedAnime(for: user)
        watchingCount = savedAnime.filter { $0.watchStatus == "watching" }.count
        planToWatchCount = savedAnime.filter { $0.watchStatus == "plan" }.count
        favouriteCount = savedAnime.filter { $0.isFavorite == true }.count
        totalAnime = watchingCount + planToWatchCount + favouriteCount

        averageGameScore = gameRepository.fetchAverageScore(for: user)
        highestGameScore = gameRepository.fetchHighScore(for: user)

        onDataUpdated?()
    }

    func updateProfileImage(_ image: UIImage?) {
        guard let user = user else { return }
        let imageData = image?.jpegData(compressionQuality: 0.8)
        userRepository.updateUser(user, profileImage: imageData)
        onDataUpdated?()
    }

    func logout() {
        userRepository.logout()
    }
}
