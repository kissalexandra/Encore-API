//
//  UserRegistration.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct UserRegistration: Content {
    internal let username: String
    internal let password: String
}

extension UserRegistration: Validatable {
    internal static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(8...))
    }
}
