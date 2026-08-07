//
//  UserLoginRequest.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct UserLoginRequest: Content {
    internal let username: String
    internal let password: String
}
