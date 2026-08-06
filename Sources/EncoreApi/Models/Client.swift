//
//  Client.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal final class Client: Model, Authenticatable, @unchecked Sendable {
    internal static let schema: String = "clients"

    @ID(key: .id)
    internal var id: UUID?

    @Field(key: "token_hash")
    internal var tokenHash: String

    @Field(key: "expiration_date")
    internal var expirationDate: Date
}
