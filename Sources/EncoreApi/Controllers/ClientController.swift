//
//  ClientController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

// TODO: define storage
// TODO: filesystem health check
// TODO: implement artworks (list all, head, get, post)
// TODO: documentation
// TODO: tests

internal struct ClientController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws {
        let group: any RoutesBuilder = routes.grouped("api", "v1", "clients")

        if AppEnvironment.isPublicClientRegistration {
            group.post("register", use: self.register(request:))
        } else {
            group.grouped(UserTokenAuthenticator(), User.guardMiddleware())
                .post("register", use: self.register(request:))
        }
    }

    internal func register(request: Request) async throws -> Response {
        let token: String = TokenGenerator.generate()

        let client: Client = .init()
        client.tokenHash = TokenGenerator.hash(token)
        client.expirationDate = Date(timeIntervalSinceNow: TimeInterval(AppEnvironment.clientTokenLifetime * 86_400))

        try await client.save(on: request.db)

        return try await ClientRegistration(token: token, expirationDate: client.expirationDate).encodeResponse(
            status: .created, for: request)
    }
}
