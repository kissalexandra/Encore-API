//
//  AppConfiguration.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal enum DatabaseDriver {
    case postgres
    case mysql
}

internal enum AppConfiguration {
    internal static var areUserRegistrationsDisabled: Bool {
        self.bool("APP_DISABLE_USER_REGISTRATIONS") ?? false
    }

    internal static var isPublicClientRegistration: Bool {
        self.bool("APP_PUBLIC_CLIENT_REGISTRATION") ?? false
    }

    internal static var clientTokenLifetime: Int {
        self.int("APP_CLIENT_TOKEN_LIFETIME") ?? 90
    }

    internal static var databaseDriver: DatabaseDriver {
        switch self.string("DATABASE_DRIVER")?.lowercased() {
            case "mysql":
                return .mysql
            default:
                return .postgres
        }
    }

    internal static var databaseHost: String {
        self.string("DATABASE_HOST") ?? "127.0.0.1"
    }

    internal static var databasePort: Int {
        self.int("DATABASE_PORT") ?? 5432
    }

    internal static var databaseUsername: String {
        self.string("DATABASE_USERNAME") ?? ""
    }

    internal static var databasePassword: String {
        self.string("DATABASE_PASSWORD") ?? ""
    }

    internal static var databaseName: String {
        self.string("DATABASE_NAME") ?? ""
    }

    private static func bool(_ key: String) -> Bool? {
        return Environment.get(key).flatMap(Bool.init(_:))
    }

    private static func int(_ key: String) -> Int? {
        return Environment.get(key).flatMap(Int.init(_:))
    }

    private static func string(_ key: String) -> String? {
        return Environment.get(key)
    }
}
