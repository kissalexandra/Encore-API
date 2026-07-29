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
        group.post("register", use: self.register)
    }

    internal func register(request: Request) async throws -> ClientRegistration {
        let token: String = ClientTokenGenerator.generate()

        let client: Client = .init()
        client.tokenHash = ClientTokenGenerator.hash(token)
        client.expirationDate = .now + .months(3)

        try await client.save(on: request.db)

        return .init(token: token, expirationDate: client.expirationDate)
    }
}
