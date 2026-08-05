//
//  StatisticsController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct StatisticsController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws -> Void {
        let group: any RoutesBuilder = routes.grouped("api", "v1").grouped(UserTokenAuthenticator(), User.guardMiddleware())
        group.on(.GET, "statistics", use: self.statistics(request:))
    }

    private func statistics(request: Request) async throws -> ArtworkStats {
        let count: Int = try await Artwork.query(on: request.db).count()
        let totalBytes: Int = try await Artwork.query(on: request.db).sum(\.$size) ?? 0
        return .init(count: count, totalBytes: totalBytes)
    }
}
