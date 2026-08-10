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

    /// Returns an artwork's absolute file path.
    ///
    /// The directory structure is built by taking the first two and next two characters
    /// to prevent storing thousands of files in a single directory: self.root/[0-1]/[2-3]/hash.jpg
    ///
    /// - Parameter hash: The artwork's content hash.
    /// - Returns: The absolute file path for an artwork.
    internal func path(for hash: String) -> String {
        let firstLevel: String = .init(hash.prefix(2))
        let secondLevel: String = .init(hash.dropFirst(2).prefix(2))
        return "\(self.root)/\(firstLevel)/\(secondLevel)/\(hash).jpg"
    }

    /// Writes an artwork's data to the disk.
    ///
    /// The bytes are staged as a hidden file next to the destination and then renamed into place,
    /// so a concurrent read never observes a partial file. Staging in the same directory keeps the
    /// rename on one filesystem, which it relies on to stay atomic. As the storage is content
    /// addressed, an already existing blob is byte-identical and left untouched.
    ///
    /// - Parameters:
    ///   - data: The artwork bytes to write.
    ///   - hash: The artwork's content hash.
    internal func write(_ data: Data, for hash: String) throws {
        let finalPath: String = self.path(for: hash)

        guard !FileManager.default.fileExists(atPath: finalPath) else {
            return
        }

        let directory: String = (finalPath as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)

        let stagingUrl: URL = .init(fileURLWithPath: "\(directory)/.\(hash).\(UUID().uuidString)")
        try data.write(to: stagingUrl)

        do {
            try FileManager.default.moveItem(at: stagingUrl, to: URL(fileURLWithPath: finalPath))
        } catch {
            try? FileManager.default.removeItem(at: stagingUrl)
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
