//
//  ArtworkStats.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct ArtworkStats: Content {
    internal let count: Int
    internal let totalBytes: Int
}
