//
//  DiscoverViewModel.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import Foundation

protocol DiscoverViewModelProtocol: AnyObject {
    var isDataLoaded: Bool { get }
    var searchResults: [Anime] { get }
    var categories: [(id: Int, name: String)] { get }
    var isSearching: Bool { get }

    var refreshUI: (() -> Void)? { get set }
    var showError: ((String) -> Void)? { get set }
    var showLoading: ((Bool) -> Void)? { get set }

    func loadInitialData() async
    func getAnime(for categoryId: Int) -> [Anime]
    func search(query: String)
    func clearSearch()
}

final class DiscoverViewModel: DiscoverViewModelProtocol {
    private let animeService = AnimeService.shared
    private(set) var isDataLoaded = false

    private(set) var searchResults: [Anime] = []
    private var animeByGenre: [Int: [Anime]] = [:]

    let categories: [(id: Int, name: String)] = [
        (0, "All"),
        (1, "Action"),
        (2, "Adventure"),
        (46, "Award Winning"),
        (4, "Comedy"),
        (8, "Drama"),
        (10, "Fantasy"),
        (14, "Horror"),
        (7, "Mystery"),
        (22, "Romance"),
        (36, "Slice of Life"),
        (37, "Supernatural")
    ]

    private(set) var isSearching = false

    var refreshUI: (() -> Void)?
    var showError: ((String) -> Void)?
    var showLoading: ((Bool) -> Void)?

    private var searchTask: Task<Void, Never>?

    func loadInitialData() async {
        guard !isDataLoaded else { return }

        showLoading?(true)

        for category in categories where category.id != 0 {
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            for attempt in 1...2 {
                do {
                    let response = try await animeService.fetchAnimeByGenre(genreId: category.id)
                    animeByGenre[category.id] = response.data
                    refreshUI?()
                    break
                } catch {
                    if attempt == 2 {
                        continue
                    }
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
            }
        }

        isDataLoaded = true
        showLoading?(false)
    }

    func getAnime(for categoryId: Int) -> [Anime] {
        return animeByGenre[categoryId] ?? []
    }

    func search(query: String) {
        searchTask?.cancel()

        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isSearching = false
            searchResults = []
            refreshUI?()
            return
        }

        isSearching = true
        showLoading?(true)

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)

            guard !Task.isCancelled else { return }

            do {
                let response = try await animeService.searchAnime(query: query)
                guard !Task.isCancelled else { return }
                searchResults = response.data
                refreshUI?()
            } catch {
                guard !Task.isCancelled else { return }
                showError?(mapError(error))
            }

            showLoading?(false)
        }
    }

    func clearSearch() {
        searchTask?.cancel()
        isSearching = false
        searchResults = []
        refreshUI?()
    }

    private func mapError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .rateLimited:
                return "Too many requests. Please wait a moment."
            case .serverError(let code):
                return "Server error (\(code)). Please try again."
            case .noData:
                return "No data received."
            case .decodingError:
                return "Failed to process data."
            default:
                return "Network error. Please check your connection."
            }
        }
        return "An error occurred. Please try again."
    }
}
