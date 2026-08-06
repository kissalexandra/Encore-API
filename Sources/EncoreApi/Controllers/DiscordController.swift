//
//  DiscordController.swift
//  Encore-API
//
//  Created by Alexandra Kiss

import Fluent
import Vapor

internal struct DiscordController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws -> Void {
        let group: any RoutesBuilder = routes.grouped("api", "v1", "discord")

        let applicationsGroup: any RoutesBuilder = group.grouped("applications")
        applicationsGroup.on(.GET, "", use: self.applications(request:))

        let userAuthenticatedApplicationsGroup: any RoutesBuilder = applicationsGroup.grouped(
            UserTokenAuthenticator(), User.guardMiddleware())
        userAuthenticatedApplicationsGroup.on(.POST, "add", use: self.addApplication(request:))
    }

    private func applications(request: Request) async throws -> [String] {
        return try await DiscordApplication.query(on: request.db).all().map(\.applicationIdentifier)
    }

    private func addApplication(request: Request) async throws -> Response {
        let application: DiscordApplication = try request.content.decode(DiscordApplication.self)
        try await application.save(on: request.db)
        return .init(status: .created)
    }
}
