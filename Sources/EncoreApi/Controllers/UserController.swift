//
//  UserController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct UserController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws -> Void {
        let group: any RoutesBuilder = routes.grouped("api", "v1", "users")
        group.post("register", use: self.register(request:))
        group.post("login", use: self.login(request:))

        let authenticated: any RoutesBuilder = group.grouped(UserTokenAuthenticator(), User.guardMiddleware())
        authenticated.post("logout", use: self.logout(request:))
    }

    internal func register(request: Request) async throws -> Response {
        guard !AppEnvironment.areUserRegistrationsDisabled else {
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
        let credentials: UserLogin = try request.content.decode(UserLogin.self)

        let user: User? = try await User.query(on: request.db)
            .filter(\.$username == credentials.username)
            .first()
        guard let user: User, try user.verify(password: credentials.password) else {
            throw Abort(.unauthorized, reason: "Invalid username or password.")
        }

        let token: String = TokenGenerator.generate()
        let expirationDate: Date = Date(timeIntervalSinceNow: TimeInterval(AppEnvironment.userTokenLifetime * 86_400))
        let userToken: UserToken = .init(
            valueHash: TokenGenerator.hash(token), expirationDate: expirationDate, userID: try user.requireID())
        try await userToken.save(on: request.db)

        return .init(token: token)
    }

    internal func logout(request: Request) async throws -> HTTPStatus {
        let token: UserToken = try request.auth.require(UserToken.self)
        try await token.delete(on: request.db)
        return .noContent
    }
}
