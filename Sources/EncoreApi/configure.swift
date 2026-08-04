//
//  configure.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import FluentMySQLDriver
import FluentPostgresDriver
import Foundation
import Vapor

internal func configure(_ app: Application) async throws {
    let decoder: JSONDecoder = .init()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    let encoder: JSONEncoder = .init()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    ContentConfiguration.global.use(encoder: encoder, for: .json)

    switch AppEnvironment.databaseDriver {
        case .postgres:
            app.databases.use(
                DatabaseConfigurationFactory.postgres(
                    configuration: .init(
                        hostname: AppEnvironment.databaseHost,
                        port: AppEnvironment.databasePort,
                        username: AppEnvironment.databaseUsername,
                        password: AppEnvironment.databasePassword,
                        database: AppEnvironment.databaseName,
                        tls: .disable)
                ), as: .psql)
        case .mysql:
            app.databases.use(
                DatabaseConfigurationFactory.mysql(
                    hostname: AppEnvironment.databaseHost,
                    port: AppEnvironment.databasePort,
                    username: AppEnvironment.databaseUsername,
                    password: AppEnvironment.databasePassword,
                    database: AppEnvironment.databaseName,
                    tlsConfiguration: nil
                ), as: .mysql)
    }

    let artworkRoot: String = app.directory.workingDirectory + "Storage/Artwork"
    try FileManager.default.createDirectory(atPath: artworkRoot, withIntermediateDirectories: true)
    app.artworkBlobStore = .init(root: artworkRoot)

    app.migrations.add(CreateUsersTable())
    app.migrations.add(CreateUserTokensTable())
    app.migrations.add(CreateClientsTable())
    app.migrations.add(CreateArtworksTable())
    app.migrations.add(CreateDiscordApplicationsTable())

    app.lifecycle.use(TokenMaintenance())

    try routes(app)
}
