//
//  ClientController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

// TODO: head existing cover
// TODO: upload cover
// TODO: filesystem health check
// TODO: documentation
// TODO: tests

internal struct ClientController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws {
        let group: any RoutesBuilder = routes.grouped("api", "v1", "client")
        group.post("register", use: self.register(request:))
    }

    internal func register(request: Request) async throws -> Response {
        guard !AppConfiguration.isClientRegistrationDisabled else {
            throw Abort(.serviceUnavailable, reason: "Client registration is disabled.")
        }

        if let secret: String = AppConfiguration.registrationSecret {
            guard request.headers.bearerAuthorization?.token == secret else {
                throw Abort(.unauthorized, reason: "Invalid or missing registration secret.")
            }
        }

        let token: String = ClientTokenGenerator.generate()

        let client: Client = .init()
        client.tokenHash = ClientTokenGenerator.hash(token)
        client.expirationDate = Date(timeIntervalSinceNow: TimeInterval(AppConfiguration.clientTokenLifetimeDays * 86_400))

        try await client.save(on: request.db)

        return try await ClientRegistration(token: token, expirationDate: client.expirationDate).encodeResponse(status: .created, for: request)
    }
}
