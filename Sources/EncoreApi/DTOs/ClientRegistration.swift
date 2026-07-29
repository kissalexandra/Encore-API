//
//  ClientRegistration.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct ClientRegistration: Content {
    internal let token: String
    internal let expirationDate: Date
}
