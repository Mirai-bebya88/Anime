//
//  NetworkManager.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case rateLimited
    case unknown(Error)
}

final class NetworkManager {
    static let shared = NetworkManager()

    private let session: URLSession
    private var lastRequestTime: Date?
    private let minimumRequestInterval: TimeInterval = 0.4

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        await enforceRateLimit()

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    private func enforceRateLimit() async {
        if let lastRequest = lastRequestTime {
            let elapsed = Date().timeIntervalSince(lastRequest)
            if elapsed < minimumRequestInterval {
                let delay = minimumRequestInterval - elapsed
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
    }
}
