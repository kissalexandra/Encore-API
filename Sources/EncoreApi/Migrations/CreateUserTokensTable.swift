//
//  CreateUserTokensTable.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent

internal struct CreateUserTokensTable: AsyncMigration {
    internal func prepare(on database: any Database) async throws {
        try await database.schema(UserToken.schema)
            .id()
            .field("value_hash", .string, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .unique(on: "value_hash")
            .create()
    }

    internal func revert(on database: any Database) async throws {
        try await database.schema(UserToken.schema).delete()
    }
}
