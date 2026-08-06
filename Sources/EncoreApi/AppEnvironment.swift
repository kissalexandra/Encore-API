//
//  AppEnvironment.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal enum DatabaseDriver {
    case postgres
    case mysql
}

internal enum AppEnvironmentError: Error, CustomStringConvertible {
    case instanceIdentifierEmpty

    internal var description: String {
        switch self {
            case .instanceIdentifierEmpty:
                return "The instance identifier must not be empty."
        }
    }
}

internal enum AppEnvironment {
    internal static var artworkLifetime: Int {
        self.int("APP_ARTWORK_LIFETIME") ?? 30
    }

    internal static var clientTokenLifetime: Int {
        self.int("APP_CLIENT_TOKEN_LIFETIME") ?? 90
    }

    internal static var instanceIdentifier: String {
        self.string("APP_INSTANCE_IDENTIFIER") ?? ""
    }

    internal static var isPublicInstance: Bool {
        self.bool("APP_INSTANCE_IS_PUBLIC") ?? false
    }

    internal static var isUserRegistrationEnabled: Bool {
        self.bool("APP_USER_ENABLE_REGISTRATION") ?? true
    }

    internal static var userTokenLifetime: Int {
        self.int("APP_USER_TOKEN_LIFETIME") ?? 30
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

    internal static var databaseName: String {
        self.string("DATABASE_NAME") ?? ""
    }

    internal static var databasePassword: String {
        self.string("DATABASE_PASSWORD") ?? ""
    }

    internal static var databasePort: Int {
        self.int("DATABASE_PORT") ?? 5432
    }

    internal static var databaseUsername: String {
        self.string("DATABASE_USERNAME") ?? ""
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
