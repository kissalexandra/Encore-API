//
//  HealthController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct HealthController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) -> Void {
        let group: any RoutesBuilder = routes.grouped("api", "v1")
        group.on(.GET, "health", use: self.health(request:))
    }

    /// Returns the health status of the app.
    ///
    /// The database connection and file system write permissions are tested.
    ///
    /// - Returns: `.ok` with the app's health status.
    private func health(request: Request) async throws -> Response {
        let dependencies: [HealthCheckDependency] = [
            await testDatabase(on: request),
            testFileSystem(on: request)
        ]

        let healthCheck: HealthCheckResponse = .init(
            status: dependencies.allSatisfy { .ok == $0.status } ? .ok : .degraded,
            dependencies: dependencies
        )

        let response: Response = .init(status: .ok == healthCheck.status ? .ok : .serviceUnavailable)
        try response.content.encode(healthCheck, as: .json)

        return response
    }

    /// Tests if the database connection is healthy.
    ///
    /// - Returns: A HealthCheckDependency object containing whether the database connection is healthy.
    private func testDatabase(on request: Request) async -> HealthCheckDependency {
        do {
            _ = try await Client.query(on: request.db).first()
            return .init(dependency: .database, status: .ok)
        } catch {
            return .init(dependency: .database, status: .degraded)
        }
    }

    /// Tests if the file system is writeable.
    ///
    /// - Returns: A HealthCheckDependency object containing whether the file system is writeable.
    private func testFileSystem(on request: Request) -> HealthCheckDependency {
        let probe: URL = URL(
            fileURLWithPath: request.application.artworkBlobStore.root
        ).appendingPathComponent(".health-\(UUID().uuidString)")

        do {
            try Data().write(to: probe)
            try FileManager.default.removeItem(at: probe)
            return .init(dependency: .filesystem, status: .ok)
        } catch {
            return .init(dependency: .filesystem, status: .degraded)
        }
    }
}
