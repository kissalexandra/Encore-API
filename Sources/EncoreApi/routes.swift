//
//  routes.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal func routes(_ app: Application) throws {
    try app.register(collection: UserController())
    try app.register(collection: ClientController())
    try app.register(collection: DiscordController())
    try app.register(collection: HealthController())
}
