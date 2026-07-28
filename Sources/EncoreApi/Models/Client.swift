import Foundation
import Fluent
import Vapor

final class Client: Model, Content, @unchecked Sendable {
    static let schema: String = "clients"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "expiration_date")
    var expirationDate: Date

    init() {
        self.expirationDate = .now + .months(3)
    }
}
