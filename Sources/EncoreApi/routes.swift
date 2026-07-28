import Vapor

internal func routes(_ app: Application) throws {
    try app.register(collection: ArtworkController())
}
