//
//  StatisticsController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct StatisticsController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) -> Void {
        let userAuthenticatedGroup: any RoutesBuilder = routes.grouped("api", "v1", "statistics").grouped(
            UserTokenAuthenticator(), User.guardMiddleware())
        userAuthenticatedGroup.on(.GET, "", use: self.statistics(request:))
    }

    private func statistics(request: Request) async throws -> StatisticsResponse {
        let count: Int = try await Artwork.query(on: request.db).count()
        let totalBytes: Int = try await Artwork.query(on: request.db).sum(\.$size) ?? 0
        return .init(count: count, totalBytes: totalBytes)
    }
}
