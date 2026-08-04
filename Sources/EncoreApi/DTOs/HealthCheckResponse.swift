//
//  HealthCheckResponse.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal enum HealthStatus: String, Codable {
    case ok
    case degraded
}

internal enum HealthDependency: String, Codable {
    case database
    case filesystem
}

internal struct HealthCheckResponse: Content {
    internal var status: HealthStatus
    internal var dependencies: [HealthCheckDependency]

    init(status: HealthStatus, dependencies: [HealthCheckDependency]) {
        self.status = status
        self.dependencies = dependencies
    }
}

internal struct HealthCheckDependency: Content {
    internal let dependency: HealthDependency
    internal let status: HealthStatus

    init(dependency: HealthDependency, status: HealthStatus) {
        self.dependency = dependency
        self.status = status
    }
}
