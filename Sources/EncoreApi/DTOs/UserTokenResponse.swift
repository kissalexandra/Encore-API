//
//  UserTokenResponse.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct UserTokenResponse: Content {
    internal let token: String
}
