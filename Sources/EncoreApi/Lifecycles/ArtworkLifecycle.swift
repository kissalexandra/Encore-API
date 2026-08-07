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
                    try await Artwork.query(on: application.db)
                        .filter(\.$expirationDate < .now)
                        .delete()
                } catch {
                    application.logger.report(error: error)
                }
            }
        }
    }
}
