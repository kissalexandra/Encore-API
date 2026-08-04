//
//  DiscordApplication.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal final class DiscordApplication: Model, Content, @unchecked Sendable {
    internal static let schema: String = "discord_applications"

    @ID(key: .id)
    internal var id: UUID?

    @Field(key: "application_identifier")
    internal var applicationIdentifier: String

    internal init() {}

    internal init(applicationIdentifier: String) {
        self.applicationIdentifier = applicationIdentifier
    }
}
