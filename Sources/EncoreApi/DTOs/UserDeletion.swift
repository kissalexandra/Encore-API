//
//  UserDeletion.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct UserDeletion: Content {
    internal let password: String
}
