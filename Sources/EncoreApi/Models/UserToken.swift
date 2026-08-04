//
//  UserToken.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Fluent
import Vapor

internal final class UserToken: Model, @unchecked Sendable {
    internal static let schema: String = "user_tokens"

    @ID(key: .id)
    internal var id: UUID?

    @Field(key: "value_hash")
    internal var valueHash: String

    @Parent(key: "user_id")
    internal var user: User

    init() {}

    init(valueHash: String, userID: User.IDValue) {
        self.valueHash = valueHash
        self.$user.id = userID
    }
}

internal struct UserTokenAuthenticator: AsyncBearerAuthenticator {
    internal func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        let valueHash: String = TokenGenerator.hash(bearer.token)

        guard
            let token: UserToken = try await UserToken.query(on: request.db)
                .filter(\.$valueHash == valueHash)
                .with(\.$user)
                .first()
        else {
            return
        }

        request.auth.login(token.user)
    }
}
