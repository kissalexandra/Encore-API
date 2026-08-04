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
        group.on(.GET, ":fileName", use: self.serve(request:))

        let managed: any RoutesBuilder = group.grouped(UserTokenAuthenticator(), User.guardMiddleware())
        managed.on(.GET, "statistics", use: self.statistics(request:))
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

    private func serve(request: Request) async throws -> Response {
        guard let fileName: String = request.parameters.get("fileName") else {
            throw Abort(.badRequest)
        }

        let key: String = fileName.hasSuffix(".jpg") ? String(fileName.dropLast(4)) : fileName
        let path: String = request.application.artworkBlobStore.path(for: key)

        guard FileManager.default.fileExists(atPath: path) else {
            throw Abort(.notFound)
        }

        let response: Response = try await request.fileio.asyncStreamFile(at: path)
        response.headers.replaceOrAdd(name: "Cache-Control", value: "public, max-age=31536000, immutable")
        response.headers.replaceOrAdd(name: "X-Content-Type-Options", value: "nosniff")

        return response
    }

    private func statistics(request: Request) async throws -> ArtworkStats {
        let count: Int = try await Artwork.query(on: request.db).count()
        let totalBytes: Int = try await Artwork.query(on: request.db).sum(\.$size) ?? 0
        return .init(count: count, totalBytes: totalBytes)
    }
}
