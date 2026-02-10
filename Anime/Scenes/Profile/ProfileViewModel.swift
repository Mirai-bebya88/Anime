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
    
    var user: User?
    var totalAnime: Int = 0
    var watchingCount: Int = 0
    var completedCount: Int = 0
    var planToWatchCount: Int = 0
    var averageGameScore: Double = 0.0
    var highestGameScore: Int32 = 0

    var onDataUpdated: (() -> Void)?

    func loadProfile() {
        user = userRepository.currentUser

        guard let user = user else {
            onDataUpdated?()
            return
        }

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
}
