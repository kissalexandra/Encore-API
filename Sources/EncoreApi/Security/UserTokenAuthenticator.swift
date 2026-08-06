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
        let tokenHash: String = TokenGenerator.hash(bearer.token)

        guard
            let token: UserToken = try await UserToken.find(tokenHash, on: request.db),
            token.expirationDate > .now
        else {
            return
        }

        let user: User = try await token.$user.get(on: request.db)

        request.auth.login(user)
        request.auth.login(token)
    }
}
