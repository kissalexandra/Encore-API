//
//  CreateUserTokensTable.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent

internal struct CreateUserTokensTable: AsyncMigration {
    internal func prepare(on database: any Database) async throws -> Void {
        try await database.schema(UserToken.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .field("token_hash", .string, .required)
            .field("expiration_date", .datetime, .required)
            .unique(on: "token_hash")
            .create()
    }

    internal func revert(on database: any Database) async throws -> Void {
        try await database.schema(UserToken.schema).delete()
    }
}
