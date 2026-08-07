//
//  ArtworkController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct ArtworkController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) -> Void {
        let group: any RoutesBuilder = routes.grouped("api", "v1", "artworks").grouped(InstanceMiddleware())

        // Discord needs to be able to reach the artworks without authentication.
        group.on(.GET, ":fileName", use: self.serve(request:))

        let clientAuthenticatedGroup: any RoutesBuilder = group.grouped(ClientTokenAuthenticator(), Client.guardMiddleware())
        clientAuthenticatedGroup.on(.HEAD, ":fileName", use: self.exists(request:))
        clientAuthenticatedGroup.on(.PUT, ":fileName", body: .collect(maxSize: "128kb"), use: self.upload(request:))
    }

    /// Returns whether an artwork exists.
    ///
    /// The instance ID is included as a header through a middleware.
    ///
    /// - Returns: `.ok` with the artwork's expiration date.
    /// - Throws: `Abort(.badRequest)` if the file name is missing or
    ///   `Abort(.notFound)` if the artwork doesn't exist.
    private func exists(request: Request) async throws -> Response {
        guard let fileName: String = request.parameters.get("fileName") else {
            throw Abort(.badRequest)
        }

        let key: String = self.sanitizeFileName(fileName: fileName)
        guard let artwork: Artwork = try await Artwork.find(key, on: request.db) else {
            throw Abort(.notFound)
        }

        let response: Response = .init()
        response.headers.replaceOrAdd(
            name: "X-Expires-At",
            value: artwork.expirationDate.ISO8601Format()
        )

        return response
    }

    /// Returns an artwork.
    ///
    /// The instance ID is included as a header through a middleware.
    ///
    /// - Returns: The artwork.
    /// - Throws: `Abort(.badRequest)` if the file name is missing or
    ///   `Abort(.notFound)` if the artwork doesn't exist.
    private func serve(request: Request) async throws -> Response {
        guard let fileName: String = request.parameters.get("fileName") else {
            throw Abort(.badRequest)
        }

        let key: String = self.sanitizeFileName(fileName: fileName)
        let path: String = request.application.artworkBlobStore.path(for: key)

        guard FileManager.default.fileExists(atPath: path) else {
            throw Abort(.notFound)
        }

        let response: Response = try await request.fileio.asyncStreamFile(at: path)
        // Immutably cache the artwork "forever".
        // Even if the artwork expires on the instance, the URL would never change, because
        // the artwork would be uploaded with the same hash again.
        response.headers.replaceOrAdd(name: "Cache-Control", value: "public, max-age=31536000, immutable")
        // Guarantee that the client interprets the artwork as a jpeg.
        response.headers.replaceOrAdd(name: "X-Content-Type-Options", value: "nosniff")

        return response
    }

    /// Uploads an artwork.
    ///
    /// The uploaded data is validated by:
    ///     1) only allowing body sizes up to 128kb
    ///     2) hashing the body against the file name (client computed hash)
    ///
    /// The artwork's expiration date is reset if it already exists instead.
    ///
    /// The instance ID is included as a header through a middleware.
    ///
    /// - Returns: `.ok` if an existing artwork's expiration date was reset or `.created` if the body was saved.
    /// - Throws: `Abort(.badRequest)` if the file name is missing or if they body is empty or the hashes mismatch
    private func upload(request: Request) async throws -> Response {
        guard let fileName: String = request.parameters.get("fileName") else {
            throw Abort(.badRequest)
        }
        let key: String = self.sanitizeFileName(fileName: fileName)

        guard let buffer: ByteBuffer = request.body.data else {
            throw Abort(.badRequest, reason: "Request body is empty.")
        }
        let bytes: Data = .init(buffer.readableBytesView)

        // Check if the body's hash matches with the client's.
        let computedKey: String = ArtworkKey.derive(from: bytes)
        guard computedKey == key else {
            throw Abort(.badRequest, reason: "Body does not hash to the given key.")
        }

        let expirationDate: Date = .init(timeIntervalSinceNow: TimeInterval(AppEnvironment.artworkLifetime * 86_400))

        // Reset the artwork's expiration date if it already exists.
        if let existingArtwork: Artwork = try await Artwork.find(key, on: request.db) {
            existingArtwork.expirationDate = expirationDate
            try await existingArtwork.save(on: request.db)

            let response: Response = .init()
            response.headers.replaceOrAdd(name: "X-Expires-At", value: expirationDate.ISO8601Format())
            return response
        }

        try request.application.artworkBlobStore.write(bytes, for: key)

        let artwork: Artwork = .init()
        artwork.id = key
        artwork.size = bytes.count
        artwork.expirationDate = expirationDate
        try await artwork.save(on: request.db)

        let response: Response = .init(status: .created)
        response.headers.replaceOrAdd(name: "X-Expires-At", value: expirationDate.ISO8601Format())
        return response
    }

    /// Returns the file name stripped of the file extension.
    ///
    /// - Parameter fileName: The file name to sanitize
    /// - Returns: The file name without file extension
    private func sanitizeFileName(fileName: String) -> String {
        return fileName.components(separatedBy: ".")[0]
    }
}
