//
//  CreateDiscordApplicationsTable.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent

internal struct CreateDiscordApplicationsTable: AsyncMigration {
    internal func prepare(on database: any Database) async throws {
        try await database.schema(DiscordApplication.schema)
            .id()
            .field("application_identifier", .string, .required)
            .unique(on: "application_identifier")
            .create()
    }

    internal func revert(on database: any Database) async throws {
        try await database.schema(DiscordApplication.schema).delete()
    }
}
