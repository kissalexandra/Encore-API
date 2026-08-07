//
//  ArtworkHasher.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Crypto
import Foundation

internal enum ArtworkHasher {
    /// Hashes an artwork's bytes into its key.
    ///
    /// The key is the first 16 bytes (in hex) of the SHA-256 of the encoded JPEG
    ///
    /// - Parameter data: The encoded artwork bytes.
    /// - Returns: The 32-character lowercase hex key.
    internal static func hash(_ data: Data) -> String {
        SHA256.hash(data: data)
            .prefix(16)
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
