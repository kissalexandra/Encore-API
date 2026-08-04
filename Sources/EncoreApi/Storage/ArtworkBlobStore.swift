//
//  ArtworkBlobStore.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Foundation
import Vapor

// Dumb blob storage on disk. Postgres remains authoritative for existence/expiry;
// this only reads and writes bytes.
internal struct ArtworkBlobStore {
    internal let root: String

    internal init(root: String) {
        self.root = root
    }

    // {root}/{h[0:2]}/{h[2:4]}/{hash}.jpg — two levels of fan-out so a busy
    // instance never puts a hundred thousand files in one directory.
    internal func path(for hash: String) -> String {
        let firstLevel: String = .init(hash.prefix(2))
        let secondLevel: String = .init(hash.dropFirst(2).prefix(2))
        return "\(self.root)/\(firstLevel)/\(secondLevel)/\(hash).jpg"
    }

    // Stages under a hidden temp name, then renames into place, so a concurrent read never
    // observes a partial file at the final path. Content-addressed, so an existing blob is
    // byte-identical — we dedup rather than rewrite.
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
            // Another writer won the race; our bytes are identical, so drop the staging file.
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
