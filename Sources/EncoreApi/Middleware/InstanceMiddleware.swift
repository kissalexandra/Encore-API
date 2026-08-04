//
//  InstanceMiddleware.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

// Stamps the instance identifier on every artwork response. The client wipes its whole local
// cache when this value changes, so a storage reset (with a rotated identifier) invalidates
// stale "still hosted" assumptions instead of serving 404s for the full retention window.
internal struct InstanceMiddleware: AsyncMiddleware {
    internal func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        let response: Response = try await next.respond(to: request)
        response.headers.replaceOrAdd(name: "X-Instance", value: AppEnvironment.instanceIdentifier)
        return response
    }
}
