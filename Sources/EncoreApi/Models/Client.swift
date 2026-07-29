//
//  Client.swift
//  Encore-API
//
//  Created by Alexandra Kiss
//

import Foundation
import Fluent
import Vapor

final internal class Client: Model, Content, @unchecked Sendable {
    static internal let schema: String = "clients"

    @ID(key: .id)
    internal var id: UUID?

    @Field(key: "expiration_date")
    internal var expirationDate: Date

    init() {
//        self.expirationDate = .now + .months(3)
        self.expirationDate = Date() + .months(3)
    }
}
