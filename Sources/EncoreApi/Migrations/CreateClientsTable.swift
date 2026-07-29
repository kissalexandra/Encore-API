//
//  CreateClientsTable.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent

internal struct CreateClientsTable: AsyncMigration {
    internal func prepare(on database: any Database) async throws {
        try await database.schema(Client.schema)
            .id()
            .field("expiration_date", .datetime, .required)
            .create()
    }

    internal func revert(on database: any Database) async throws {
        try await database.schema(Client.schema).delete()
    }
}
