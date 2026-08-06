//
//  ArtworkStatisticsResponse.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct ArtworkStatisticsResponse: Content {
    internal let count: Int
    internal let totalBytes: Int
}
