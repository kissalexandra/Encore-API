//
//  InstanceMiddleware.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Vapor

internal struct InstanceMiddleware: AsyncMiddleware {
    internal func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        let response: Response = try await next.respond(to: request)
        response.headers.replaceOrAdd(name: "X-Instance", value: AppEnvironment.instanceIdentifier)
        return response
    }
}
