import Fluent
import Vapor

// TODO: implementation
// TODO: code style
// TODO: documentation

internal struct ArtworkController: RouteCollection {
    internal func boot(routes: any RoutesBuilder) throws {
        let artworkGroup: any RoutesBuilder = routes.grouped("artwork")
        artworkGroup.get(use: self.index)
    }

    internal func index(request: Request) async throws -> String {
        return "hello world"
    }
}
