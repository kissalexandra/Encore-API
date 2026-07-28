import Fluent
import FluentPostgresDriver
import Vapor

internal func configure(_ app: Application) async throws {
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "127.0.0.1",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "17c05743637ec2c619ff517060c005fe",
        database: Environment.get("DATABASE_NAME") ?? "encore",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    try routes(app)
}
