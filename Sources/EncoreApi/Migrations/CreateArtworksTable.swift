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
            .id()
            .field("file_name", .string, .required)
            .field("expiration_date", .datetime, .required)
            .unique(on: "file_name")
            .create()
    }

    internal func revert(on database: any Database) async throws -> Void {
        try await database.schema(Artwork.schema).delete()
    }
}
