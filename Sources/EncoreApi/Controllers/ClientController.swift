//
//  ClientController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

// TODO: code documentation
// TODO: rate limitting
// TODO: docker image
// TODO: hosting documentation
// TODO: tests

internal struct ClientController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws -> Void {
        let group: any RoutesBuilder = routes.grouped("api", "v1", "clients")

        if AppEnvironment.isPublicClientRegistrationEnabled {
            group.on(.POST, "register", use: self.register(request:))
        } else {
            group.grouped(UserTokenAuthenticator(), User.guardMiddleware())
                .on(.POST, "register", use: self.register(request:))
        }
    }

    private func register(request: Request) async throws -> Response {
        let token: String = TokenGenerator.generate()

        let client: Client = .init()
        client.tokenHash = TokenGenerator.hash(token)
        client.expirationDate = Date(timeIntervalSinceNow: TimeInterval(AppEnvironment.clientTokenLifetime * 86_400))

        try await client.save(on: request.db)

        return try await ClientRegistrationResponse(token: token, expirationDate: client.expirationDate).encodeResponse(
            status: .created, for: request)
    }
}
