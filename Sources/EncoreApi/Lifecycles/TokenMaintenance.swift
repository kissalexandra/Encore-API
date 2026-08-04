//
//  TokenMaintenance.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import NIOCore
import Vapor

internal struct TokenMaintenance: LifecycleHandler {
    internal func didBootAsync(_ application: Application) async throws -> Void {
        application.eventLoopGroup.any().scheduleRepeatedAsyncTask(
            initialDelay: .hours(1),
            delay: .hours(1)
        ) { _ in
            application.eventLoopGroup.any().makeFutureWithTask {
                do {
                    try await UserToken.query(on: application.db)
                        .filter(\.$expirationDate < Date())
                        .delete()
                } catch {
                    application.logger.report(error: error)
                }
            }
        }
    }
}
