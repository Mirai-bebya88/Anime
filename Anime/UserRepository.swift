//
//  UserRepository.swift
//  Anime
//
//  Created by elene malakmadze on 02.02.26.
//

import CoreData
import CryptoKit
import Foundation

final class UserRepository {
    static let shared = UserRepository()
    private let coreData = CoreDataManager.shared

    private init() {}

    private var currentUserKey = "currentUserId"

    var currentUser: User? {
        guard let userIdString = UserDefaults.standard.string(forKey: currentUserKey),
              let userId = UUID(uuidString: userIdString) else {
            return nil
        }
        return fetchUser(by: userId)
    }

    func createUser(username: String, lastName: String, password: String) -> User? {
        let user = User(context: coreData.context)
        user.id = UUID()
        user.username = username
        user.password = hashPassword(password)
        user.memberSince = Date()

        coreData.saveContext()
        setCurrentUser(user)
        return user
    }

    func login(username: String, password: String) -> User? {
        guard let user = fetchUser(by: username) else { return nil }

        if verifyPassword(password, against: user.password ?? "") {
            setCurrentUser(user)
            return user
        }
        return nil
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }

    func userExists(username: String) -> Bool {
        return fetchUser(by: username) != nil
    }

    func userExistsWithCredentials(username: String, password: String) -> Bool {
        guard let user = fetchUser(by: username) else { return false }
        return verifyPassword(password, against: user.password ?? "")
    }

    func fetchUser(by username: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username ==[c] %@", username)
        request.fetchLimit = 1
        return coreData.fetch(request).first
    }

    func fetchUser(by id: UUID) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return coreData.fetch(request).first
    }

    func updateUser(_ user: User, profileImage: Data?) {
        user.profileImage = profileImage
        coreData.saveContext()
    }

    private func setCurrentUser(_ user: User) {
        UserDefaults.standard.set(user.id?.uuidString, forKey: currentUserKey)
    }

    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func verifyPassword(_ password: String, against hash: String) -> Bool {
        return hashPassword(password) == hash
    }
}
