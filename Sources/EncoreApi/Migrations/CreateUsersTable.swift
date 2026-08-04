//
//  CreateUsersTable.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent

internal struct CreateUsersTable: AsyncMigration {
    internal func prepare(on database: any Database) async throws -> Void {
        try await database.schema(User.schema)
            .id()
            .field("username", .string, .required)
            .field("password_hash", .string, .required)
            .unique(on: "username")
            .create()
    }

    internal func revert(on database: any Database) async throws -> Void {
        try await database.schema(User.schema).delete()
    }
}
