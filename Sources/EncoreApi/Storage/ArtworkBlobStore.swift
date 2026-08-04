//
//  ArtworkBlobStore.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

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
