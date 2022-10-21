import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "pxlshpr",
        password: Environment.get("DATABASE_PASSWORD") ?? "Ch1ll0ut",
        database: Environment.get("DATABASE_NAME") ?? "prep"
    ), as: .psql)

//    app.migrations.add(CreateSize())
    app.migrations.add(CreateFood())

    app.http.server.configuration.port = 8083

    // register routes
    try routes(app)
}
