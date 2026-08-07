//
//  StatisticsResponse.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct StatisticsResponse: Content {
    internal let count: Int
    internal let totalBytes: Int
}
