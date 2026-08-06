//
//  UserToken.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal final class UserToken: Model, Authenticatable, @unchecked Sendable {
    internal static let schema: String = "user_tokens"

    @ID(custom: "token_hash", generatedBy: .user)
    internal var id: String?

    @Field(key: "expiration_date")
    internal var expirationDate: Date

    @Parent(key: "user_id")
    internal var user: User

    internal init() {}

    internal init(tokenHash: String, expirationDate: Date, userId: User.IDValue) {
        self.id = tokenHash
        self.expirationDate = expirationDate
        self.$user.id = userId
    }
}
