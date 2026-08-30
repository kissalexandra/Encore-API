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

    // Using a 64 bit Integer would make aggregating to Decimal necessary for PostgreSQL support
    // when using query functions like `.sum()`.
    // Since the artworks are capped at 128kb it doesn't matter.
    @Field(key: "size")
    internal var size: Int32
}
