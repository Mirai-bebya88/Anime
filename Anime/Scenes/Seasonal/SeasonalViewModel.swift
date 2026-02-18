//
//  SeasonalViewModel.swift
//  Anime
//
//  Created by elene malakmadze on 13.02.26.
//

import Foundation

protocol SeasonalViewModelProtocol: AnyObject {
    var filteredAnime: [Anime] { get }
    var selectedDay: String { get }

    var refreshUI: (() -> Void)? { get set }
    var showError: ((String) -> Void)? { get set }
    var showLoading: ((Bool) -> Void)? { get set }

    func loadSeasonalAnime() async
    func filterByDay(_ day: String)
}

final class SeasonalViewModel: SeasonalViewModelProtocol {
    private let animeService = AnimeService.shared

    private var allSeasonalAnime: [Anime] = []
    private(set) var filteredAnime: [Anime] = []
    private(set) var selectedDay: String = ""

    var refreshUI: (() -> Void)?
    var showError: ((String) -> Void)?
    var showLoading: ((Bool) -> Void)?

    private let dayMapping: [String: String] = [
        "Mon": "Mondays",
        "Tue": "Tuesdays",
        "Wed": "Wednesdays",
        "Thu": "Thursdays",
        "Fri": "Fridays",
        "Sat": "Saturdays",
        "Sun": "Sundays"
    ]

    func loadSeasonalAnime() async {
        showLoading?(true)

        do {
            var allAnime: [Anime] = []
            var page = 1
            var hasNextPage = true

            while hasNextPage && page <= 3 {
                let response = try await animeService.fetchSeasonalAnime(page: page)
                allAnime.append(contentsOf: response.data)
                hasNextPage = response.pagination?.hasNextPage ?? false
                page += 1

                try? await Task.sleep(nanoseconds: 400_000_000)
            }

            allSeasonalAnime = allAnime
            filterByDay(selectedDay)
        } catch {
            showError?(mapError(error))
        }

        showLoading?(false)
    }

    func filterByDay(_ day: String) {
        selectedDay = day
        let fullDayName = dayMapping[day] ?? day

        filteredAnime = allSeasonalAnime.filter { anime in
            guard let broadcastDay = anime.broadcast?.day else { return false }
            return broadcastDay.contains(fullDayName)
        }.sorted { anime1, anime2 in
            let time1 = anime1.broadcast?.time ?? "99:99"
            let time2 = anime2.broadcast?.time ?? "99:99"
            return time1 < time2
        }

        refreshUI?()
    }

    private func mapError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .rateLimited:
                return "Too many requests. Please wait a moment."
            default:
                return "Failed to load seasonal anime."
            }
        }
        return "An error occurred."
    }
}
