//
//  UserDeletionRequest.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct UserDeletionRequest: Content {
    internal let password: String
}
