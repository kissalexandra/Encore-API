//
//  UserController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct UserController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws {
        let group: any RoutesBuilder = routes.grouped("api", "v1", "users")
        group.post("register", use: self.register(request:))

        let passwordProtected: any RoutesBuilder = group.grouped(User.authenticator())
        passwordProtected.post("login", use: self.login(request:))
    }

    internal func register(request: Request) async throws -> Response {
        guard !AppConfiguration.areUserRegistrationsDisabled else {
            throw Abort(.serviceUnavailable, reason: "User registration is disabled.")
        }

        try UserRegistration.validate(content: request)
        let registration: UserRegistration = try request.content.decode(UserRegistration.self)

        let existing: User? = try await User.query(on: request.db)
            .filter(\.$username == registration.username)
            .first()
        guard existing == nil else {
            throw Abort(.conflict, reason: "Username is already taken.")
        }

        let user: User = .init(
            username: registration.username,
            passwordHash: try Bcrypt.hash(registration.password)
        )
        try await user.save(on: request.db)

        return .init(status: .created)
    }

    internal func login(request: Request) async throws -> UserTokenResponse {
        let user: User = try request.auth.require(User.self)

        let token: String = TokenGenerator.generate()
        let userToken: UserToken = .init(valueHash: TokenGenerator.hash(token), userID: try user.requireID())
        try await userToken.save(on: request.db)

        return .init(token: token)
    }
}
