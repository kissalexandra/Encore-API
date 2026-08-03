//
//  AppConfiguration.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal enum AppConfiguration {
    internal static var isApplicationCreationDisabled: Bool {
        self.flag("APP_DISABLE_APPLICATION_CREATION")
    }

    internal static var isClientRegistrationDisabled: Bool {
        self.flag("APP_DISABLE_CLIENT_REGISTRATION")
    }

    internal static var registrationSecret: String? {
        Environment.get("APP_REGISTRATION_SECRET")
    }

    internal static var clientTokenLifetimeDays: Int {
        Environment.get("APP_CLIENT_TOKEN_LIFETIME_DAYS").flatMap(Int.init(_:)) ?? 90
    }

    private static func flag(_ key: String) -> Bool {
        Environment.get(key).flatMap(Bool.init(_:)) ?? false
    }
}
