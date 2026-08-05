//
//  ArtworkController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct ArtworkController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws -> Void {
        let group: any RoutesBuilder = routes.grouped("api", "v1", "artworks").grouped(InstanceMiddleware())
        group.on(.HEAD, ":fileName", use: self.exists(request:))
        group.on(.GET, ":fileName", use: self.serve(request:))
        group.on(.PUT, ":fileName", body: .collect(maxSize: "256kb"), use: self.upload(request:))
    }

    private func exists(request: Request) async throws -> Response {
        guard let fileName: String = request.parameters.get("fileName") else {
            throw Abort(.badRequest)
        }

        guard let artwork: Artwork = try await Artwork.find(fileName, on: request.db) else {
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

    private func upload(request: Request) async throws -> Response {
        guard let fileName: String = request.parameters.get("fileName") else {
            throw Abort(.badRequest)
        }
        let key: String = fileName.hasSuffix(".jpg") ? String(fileName.dropLast(4)) : fileName

        guard let buffer = request.body.data else {
            throw Abort(.badRequest, reason: "Request body is empty.")
        }
        let bytes: Data = .init(buffer.readableBytesView)

        let computedKey: String = ArtworkKey.derive(from: bytes)
        guard computedKey == key else {
            throw Abort(.badRequest, reason: "Body does not hash to the given key.")
        }

        let expirationDate: Date = .init(
            timeIntervalSinceNow: TimeInterval(AppEnvironment.artworkLifetime * 86_400)
        )

        if let existing: Artwork = try await Artwork.find(fileName, on: request.db) {
            existing.expirationDate = expirationDate
            try await existing.save(on: request.db)
            return self.makeResponse(status: .ok, expirationDate: expirationDate)
        }

        try request.application.artworkBlobStore.write(bytes, for: key)

        let artwork: Artwork = .init()
        artwork.id = fileName
        artwork.size = bytes.count
        artwork.expirationDate = expirationDate
        try await artwork.save(on: request.db)

        return self.makeResponse(status: .created, expirationDate: expirationDate)
    }

    private func makeResponse(status: HTTPStatus, expirationDate: Date) -> Response {
        let response: Response = .init(status: status)
        response.headers.replaceOrAdd(
            name: "X-Expires-At",
            value: ISO8601DateFormatter().string(from: expirationDate)
        )
        return response
    }
}
