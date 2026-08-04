//
//  ArtworkController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Foundation
import Vapor

internal struct ArtworkController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws -> Void {
        let group: any RoutesBuilder = routes.grouped("api", "v1", "artworks")
        group.on(.HEAD, ":fileName", use: self.exists(request:))
    }

    private func exists(request: Request) async throws -> Response {
        guard let fileName: String = request.parameters.get("fileName") else {
            throw Abort(.badRequest)
        }

        let artwork: Artwork? = try await Artwork.query(on: request.db)
            .filter(\.$fileName == fileName)
            .first()

        guard let artwork: Artwork else {
            throw Abort(.notFound)
        }

        let response: Response = .init(status: .ok)
        response.headers.replaceOrAdd(
            name: "X-Expires-At",
            value: ISO8601DateFormatter().string(from: artwork.expirationDate)
        )
        return response
    }
}
