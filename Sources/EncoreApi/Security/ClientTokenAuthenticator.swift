//
//  ClientTokenAuthenticator.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct ClientTokenAuthenticator: AsyncBearerAuthenticator {
    internal func authenticate(bearer: BearerAuthorization, for request: Request) async throws -> Void {
        let tokenHash: String = TokenGenerator.hash(bearer.token)

        guard
            let client: Client = try await Client.query(on: request.db)
                .filter(\.$tokenHash == tokenHash)
                .first(),
            client.expirationDate > .now
        else {
            return
        }

        request.auth.login(client)
    }
}
