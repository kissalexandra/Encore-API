//
//  UserTokenAuthenticator.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal struct UserTokenAuthenticator: AsyncBearerAuthenticator {
    internal func authenticate(bearer: BearerAuthorization, for request: Request) async throws -> Void {
        let valueHash: String = TokenGenerator.hash(bearer.token)

        guard
            let token: UserToken = try await UserToken.query(on: request.db)
                .filter(\.$valueHash == valueHash)
                .with(\.$user)
                .first(),
            token.isValid
        else {
            return
        }

        request.auth.login(token.user)
        request.auth.login(token)
    }
}
