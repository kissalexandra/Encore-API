//
//  ClientRegistrationResponse.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct ClientRegistrationResponse: Content {
    internal let token: String
    internal let expirationDate: Date
}
