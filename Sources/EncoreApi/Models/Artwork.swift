//
//  Client.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal final class Artwork: Model, @unchecked Sendable {
    static internal let schema: String = "artworks"

    @ID(custom: "hash", generatedBy: .user)
    internal var id: String?

    @Field(key: "expiration_date")
    internal var expirationDate: Date

    @Field(key: "size")
    internal var size: Int
}
