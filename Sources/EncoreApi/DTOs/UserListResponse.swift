//
//  UserListResponse.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct UserListResponse: Content {
    internal let id: UUID
    internal let username: String

    internal init(user: User) throws {
        self.id = try user.requireID()
        self.username = user.username
    }
}
