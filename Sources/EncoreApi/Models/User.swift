//
//  User.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal final class User: Model, @unchecked Sendable {
    internal static let schema: String = "users"

    @ID(key: .id)
    internal var id: UUID?

    @Field(key: "username")
    internal var username: String

    @Field(key: "password_hash")
    internal var passwordHash: String

    internal init() {}

    internal init(username: String, passwordHash: String) {
        self.username = username
        self.passwordHash = passwordHash
    }
}

extension User: ModelAuthenticatable {
    internal static let usernameKey: KeyPath<User, Field<String>> = \User.$username
    internal static let passwordHashKey: KeyPath<User, Field<String>> = \User.$passwordHash

    internal func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
