//
//  Client.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

final internal class Artwork: Model, @unchecked Sendable {
    static internal let schema: String = "artworks"

    @ID(key: .id)
    internal var id: UUID?

    @Field(key: "file_name")
    internal var fileName: String

    @Field(key: "expiration_date")
    internal var expirationDate: Date
}
