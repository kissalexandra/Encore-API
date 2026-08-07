//
//  DiscordController.swift
//  Encore-API
//
//  Created by Alexandra Kiss

import Fluent
import Vapor

internal struct DiscordController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) -> Void {
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

    private func addApplication(request: Request) async throws -> HTTPStatus {
        let application: DiscordApplication = try request.content.decode(DiscordApplication.self)

        let existingApplication: DiscordApplication? = try await DiscordApplication.query(
            on: request.db).filter(\.$applicationIdentifier == application.applicationIdentifier).first()
        guard nil == existingApplication else {
            throw Abort(.conflict, reason: "Application already exists.")
        }

        try await application.save(on: request.db)
        return .created
    }
}
