//
//  ClientController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

// TODO: register client (client app, rate limitting?)
// TODO: head existing cover
// TODO: upload cover
// TODO: code style
// TODO: documentation

internal struct ClientController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws {
        let groupe: any RoutesBuilder = routes.grouped("client")
        groupe.get("register", use: self.register)
    }

    internal func register(request: Request) async throws -> Client {
        let client: Client = .init()
        try await client.save(on: request.db)
        return client
    }
}
