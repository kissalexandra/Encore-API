//
//  ArtworkKey.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Crypto
import Foundation

internal enum ArtworkKey {
    internal static func derive(from data: Data) -> String {
        SHA256.hash(data: data)
            .prefix(16)
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
