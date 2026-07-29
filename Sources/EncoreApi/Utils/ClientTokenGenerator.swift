//
//  ClientTokenGenerator.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Foundation
import Crypto

internal enum ClientTokenGenerator {
    internal static func generate() -> String {
        let key: SymmetricKey = .init(size: .bits256)
        let bytes: [UInt8] = key.withUnsafeBytes(Array.init)

        return Data(bytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    internal static func hash(_ token: String) -> String {
        SHA256.hash(data: Array(token.utf8))
            .map {
                String(format: "%02x", $0)
            }
            .joined()
    }
}
