//
//  HealthController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct HealthController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws -> Void {
        let group: any RoutesBuilder = routes.grouped("api", "v1")
        group.get("health", use: self.health(request:))
    }

    internal func health(request: Request) async throws -> Response {
        let dependencies: [HealthCheckDependency] = [
            await testDatabase(on: request),
            testFileSystem(on: request)
        ]

        let healthCheck: HealthCheckResponse = .init(
            status: dependencies.allSatisfy { $0.status == .ok } ? .ok : .degraded,
            dependencies: dependencies
        )

        let response: Response = .init(status: healthCheck.status == .ok ? .ok : .serviceUnavailable)
        try response.content.encode(healthCheck, as: .json)

        return response
    }

    private func testDatabase(on request: Request) async -> HealthCheckDependency {
        do {
            _ = try await Client.query(on: request.db).first()
            return .init(dependency: .database, status: .ok)
        } catch {
            return .init(dependency: .database, status: .degraded)
        }
    }

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
