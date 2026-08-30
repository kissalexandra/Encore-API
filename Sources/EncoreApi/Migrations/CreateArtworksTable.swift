//
//  CreateArtworksTable.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent

internal struct CreateArtworksTable: AsyncMigration {
    internal func prepare(on database: any Database) async throws -> Void {
        try await database.schema(Artwork.schema)
            .field("hash", .string, .identifier(auto: false))
            .field("expiration_date", .datetime, .required)
            .field("size", .int32, .required)
            .create()
    }

    internal func revert(on database: any Database) async throws -> Void {
        try await database.schema(Artwork.schema).delete()
    }
}
