//
//  UserLogin.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct UserLogin: Content {
    internal let username: String
    internal let password: String
}
