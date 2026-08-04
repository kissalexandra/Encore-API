//
//  ArtworkBlobStore.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Foundation
import Vapor

internal struct ArtworkBlobStore {
    internal let root: String

    internal init(root: String) {
        self.root = root
    }

    internal func path(for hash: String) -> String {
        let firstLevel: String = .init(hash.prefix(2))
        let secondLevel: String = .init(hash.dropFirst(2).prefix(2))
        return "\(self.root)/\(firstLevel)/\(secondLevel)/\(hash).jpg"
    }

    internal func write(_ data: Data, for hash: String) throws {
        let finalPath: String = self.path(for: hash)

        guard !FileManager.default.fileExists(atPath: finalPath) else {
            return
        }

        let directory: String = (finalPath as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)

        let stagingURL: URL = .init(fileURLWithPath: "\(directory)/.\(hash).\(UUID().uuidString)")
        try data.write(to: stagingURL)

        do {
            try FileManager.default.moveItem(at: stagingURL, to: URL(fileURLWithPath: finalPath))
        } catch {
            try? FileManager.default.removeItem(at: stagingURL)
        }
    }
}

extension Application {
    private struct ArtworkBlobStoreKey: StorageKey {
        typealias Value = ArtworkBlobStore
    }

    internal var artworkBlobStore: ArtworkBlobStore {
        get {
            guard let store: ArtworkBlobStore = self.storage[ArtworkBlobStoreKey.self] else {
                fatalError("ArtworkBlobStore is not configured. Set app.artworkBlobStore in configure(_:).")
            }
            return store
        }
        set {
            self.storage[ArtworkBlobStoreKey.self] = newValue
        }
    }
}
