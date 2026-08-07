//
//  UserController.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct UserController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) -> Void {
        let group: any RoutesBuilder = routes.grouped("api", "v1", "users")
        group.on(.POST, "register", use: self.register(request:))
        group.on(.POST, "login", use: self.login(request:))

        let userAuthenticatedGroup: any RoutesBuilder = group.grouped(UserTokenAuthenticator(), User.guardMiddleware())
        userAuthenticatedGroup.on(.POST, "logout", use: self.logout(request:))
        userAuthenticatedGroup.on(.DELETE, ":userId", use: self.delete(request:))
    }

    private func register(request: Request) async throws -> HTTPStatus {
        guard AppEnvironment.isUserRegistrationEnabled else {
            throw Abort(.serviceUnavailable, reason: "User registration is disabled.")
        }

        try UserRegistration.validate(content: request)
        let registration: UserRegistration = try request.content.decode(UserRegistration.self)

        let existingUser: User? = try await User.query(on: request.db)
            .filter(\.$username == registration.username)
            .first()
        guard nil == existingUser else {
            throw Abort(.conflict, reason: "Username is already taken.")
        }

        let user: User = .init(
            username: registration.username,
            passwordHash: try Bcrypt.hash(registration.password)
        )
        try await user.save(on: request.db)

        return .created
    }

    private func login(request: Request) async throws -> UserTokenResponse {
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
            tokenHash: TokenGenerator.hash(token), expirationDate: expirationDate, userId: try user.requireID())
        try await userToken.save(on: request.db)

        return .init(token: token)
    }

    private func logout(request: Request) async throws -> HTTPStatus {
        let token: UserToken = try request.auth.require(UserToken.self)
        try await token.delete(on: request.db)
        return .noContent
    }

    private func delete(request: Request) async throws -> HTTPStatus {
        let actor: User = try request.auth.require(User.self)

        let userDeletion: UserDeletion = try await .decodeRequest(request)
        guard try actor.verify(password: userDeletion.password) else {
            throw Abort(.unauthorized, reason: "Password is incorrect.")
        }

        guard let userId: UUID = request.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let user: User = try await User.find(userId, on: request.db) else {
            throw Abort(.notFound)
        }

        try await user.delete(on: request.db)

        return .noContent
    }
}
