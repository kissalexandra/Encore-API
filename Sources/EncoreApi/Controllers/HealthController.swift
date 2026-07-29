//
//  HealthController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct HealthController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws {
        let group: any RoutesBuilder = routes.grouped("api", "v1")
        group.get("health", use: self.health)
    }

    internal func health(request: Request) async throws -> Response {
        var dependencies: [HealthCheckDependency] = []

        do {
            _ = try await Client.query(on: request.db).first()
            dependencies.append(.init(dependency: .database, status: .ok))
        } catch {
            dependencies.append(.init(dependency: .database, status: .degraded))
        }

        dependencies.append(.init(dependency: .filesystem, status: .degraded))

        var healthCheck: HealthCheck = .init(status: .ok)
        if dependencies.contains(where: { $0.status != .ok }) {
            healthCheck.status = .degraded
        }
        healthCheck.dependencies = dependencies

        let response: Response = .init(status: healthCheck.status == .ok ? .ok : .serviceUnavailable)
        try response.content.encode(healthCheck, as: .json)

        return response
    }
}
