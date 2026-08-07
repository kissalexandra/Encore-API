//
//  ArtworkLifecycle.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct ArtworkLifecycle: LifecycleHandler {
    internal func didBootAsync(_ application: Application) async throws -> Void {
        application.eventLoopGroup.any().scheduleRepeatedAsyncTask(initialDelay: .hours(1), delay: .hours(1)) { _ in
            application.eventLoopGroup.any().makeFutureWithTask {
                do {
                    let expiredArtworks: [Artwork] = try await Artwork.query(on: application.db)
                        .filter(\.$expirationDate < .now)
                        .all()

                    for artwork in expiredArtworks {
                        let path: String = try application.artworkBlobStore.path(for: artwork.requireID())
                        try await artwork.delete(on: application.db)
                        try? FileManager.default.removeItem(atPath: path)
                    }
                } catch {
                    application.logger.report(error: error)
                }
            }
        }
    }
}
