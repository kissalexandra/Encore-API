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

    @ID(key: .id)
    internal var id: UUID?

    @Field(key: "value_hash")
    internal var valueHash: String

    @Field(key: "expiration_date")
    internal var expirationDate: Date

    @Parent(key: "user_id")
    internal var user: User

    init() {}

    init(valueHash: String, expirationDate: Date, userID: User.IDValue) {
        self.valueHash = valueHash
        self.expirationDate = expirationDate
        self.$user.id = userID
    }

    internal var isValid: Bool {
        self.expirationDate > Date()
    }
}
