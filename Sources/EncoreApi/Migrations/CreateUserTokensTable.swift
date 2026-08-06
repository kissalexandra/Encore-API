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
            .field("token_hash", .string, .identifier(auto: false))
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .field("expiration_date", .datetime, .required)
            .create()
    }

    internal func revert(on database: any Database) async throws -> Void {
        try await database.schema(UserToken.schema).delete()
    }
}
